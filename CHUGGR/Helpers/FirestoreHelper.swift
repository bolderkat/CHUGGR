//
//  FirestoreHelper.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/7/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirestoreHelper {
    private let db = Firestore.firestore()
    private(set) var currentUser: CurrentUser?
    private(set) var friends: [FriendSnippet] = []
    private var userListeners: [ListenerRegistration] = []
    private var betDashboardListeners: [ListenerRegistration] = []
    private var friendsListener: ListenerRegistration?
    private var allUserListener: ListenerRegistration?
    
    // Storing bet queries and last bet of each query for paginated population of infinitely scrolling table view
    private var otherBetQuery: Query?
    private var lastBet: QueryDocumentSnapshot?
    
    // MARK:- User CRUD
    func createNewUser(
        firstName: String,
        lastName: String,
        userName: String,
        bio: String,
        ifUserNameTaken: @escaping (() -> ()),
        completion: (() -> ())?
    ) {
        // Get userID and email and instantiate current user
        guard let uid = Auth.auth().currentUser?.uid,
              let email = Auth.auth().currentUser?.email else {
            // TODO: Display error message instead of crashing
            fatalError("Error detecting authorized user for user creation")
        }
        let emptyDrinks = Drinks(beers: 0, shots: 0)
        let user = CurrentUser(
            uid: uid,
            email: email,
            firstName: firstName,
            lastName: lastName,
            userName: userName,
            bio: bio,
            numBets: 0,
            numFriends: 0,
            betsWon: 0, betsLost: 0,
            drinksGiven: emptyDrinks,
            drinksReceived: emptyDrinks,
            drinksOutstanding: emptyDrinks,
            recentFriends: [String]()
        )
        
        
        // Check if user name is already in use
        let docRef = db.collection(K.Firestore.users).whereField(K.Firestore.userName, isEqualTo: userName)
        docRef.getDocuments { [weak self] (document, error) in
            if let error = error {
                print("Error completing query for existing username: \(error)")
            } else {
                if document?.count == 0 {
                    // No existing user found with that usernamename. Proceed with user write.
                    self?.writeNewUser(user, completion: completion)
                } else {
                    // Existing user found with specified username
                    ifUserNameTaken()
                }
            }
        }
    }
    
    // Notes from Ian call: pass result type or bool in as completion block from createUser
    func writeNewUser(_ user: CurrentUser, completion: (() ->())?) {
        let ref = db.collection(K.Firestore.users).document(user.uid)
        do {
            try ref.setData(from: user)
            readUserOnLogin(
                with: user.uid,
                completion: completion,
                onUserDocNotFound: nil,
                failure: nil
            )
        } catch {
            print("Error writing new user to db")
        }
    }
    
    // Notes from Ian call: can consolidate all these closures with custom Error enum
    func readUserOnLogin(
        with uid: String,
        completion: (() -> ())?,
        onUserDocNotFound: (() -> ())?,
        failure: (() -> ())?
    ) {
        db.collection(K.Firestore.users).whereField(K.Firestore.uid, isEqualTo: uid)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let document = querySnapshot?.documents.first else {
                    if let error = error {
                        print("Error fetching documents: \(error)")
                    }
                    onUserDocNotFound?()
                    return
                    // TODO: Better error handling
                }
                let result = Result {
                    try document.data(as: CurrentUser.self)
                }
                switch result {
                case .success(let user):
                    if let user = user {
                        self?.currentUser = user
                        // If successful, add a snapshot for this document.
                        self?.addCurrentUserListener(with: uid)
                        
                        DispatchQueue.main.async {
                            completion?()
                        }
                    } else {
                        print("Document does not exist")
                        onUserDocNotFound?()
                    }
                case .failure(let error):
                    print("Error decoding user: \(error)")
                    failure?()
                }
            }
        
    }
    
    func addCurrentUserListener(with uid: String) {
        let listener = self.db.collection(K.Firestore.users).whereField(K.Firestore.uid, isEqualTo: uid)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let document = querySnapshot?.documents.first else {
                    if let error = error {
                        print("Error fetching documents: \(error)")
                    }
                    return
                    // TODO: Better error handling
                }
                let result = Result {
                    try document.data(as: CurrentUser.self)
                }
                switch result {
                case .success(let user):
                    if let user = user {
                        self?.currentUser = user
                        // TODO: is this where we call the main thread?
                        
                    } else {
                        print("Document does not exist")
                    }
                case .failure(let error):
                    print("Error decoding user: \(error)")
                }
            }
        userListeners.append(listener)
    }
    
    
    
    
    
    // MARK:- Bet CRUD
    func writeNewBet(bet: inout Bet) -> BetID? {
        let ref = db.collection(K.Firestore.bets).document()
        bet.setBetID(withID: ref.documentID) // add auto-gen betID to bet for reads
        do {
            
            try ref.setData(from: bet)
        } catch {
            print("Error writing bet to db")
            return nil
            // TODO: full error handling
        }
        return ref.documentID
    }
    
    func readBet(withBetID id: BetID?, completion: @escaping (_ bet: Bet) -> ()) {
        guard let id = id else { return }
        self.db.collection(K.Firestore.bets).whereField(K.Firestore.betID, isEqualTo: id)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    let document = querySnapshot!.documents.first
                    let result = Result {
                        try document?.data(as: Bet.self)
                    }
                    switch result {
                    case .success(let betFromDoc):
                        if let unwrappedBet = betFromDoc {
                            // Successfully initialized a Bet value from QuerySnapshot
                            // call and pass completion to getBetFirstNames
                            completion(unwrappedBet)
                        } else {
                            // A nil value was successfully initialized from the QuerySnapshot,
                            // or the DocumentSnapshot was nil.
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        // A Bet value could not be initialized from the QuerySnapshot.
                        print("Error decoding bet: \(error)")
                    }
                }
            }
    }
    
    func addPendingBetsListener(completion: @escaping (_ bets: [Bet]) -> ()) {
        guard let uid = currentUser?.uid,
              let firstName = currentUser?.firstName else { return }
        
        // Query for all bets user where user is invited and has not yet taken a side
        // Use listener to alert user to new bets in realtime
        let listener = db.collection(K.Firestore.bets)
            .whereField(K.Firestore.invitedUsers, arrayContains: [uid: firstName])
            .order(by: K.Firestore.dateOpened, descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    // TODO: better error handling to display to user
                    print("Error getting documents: \(error)")
                } else {
                    var bets = [Bet]()
                    for document in querySnapshot!.documents {
                        let result = Result {
                            try document.data(as: Bet.self)
                        }
                        switch result {
                        case .success(let bet):
                            if let unwrappedBet = bet {
                                // Successfully initialized a Bet value from QuerySnapshot
                                // Add bet to bets array.
                                bets.append(unwrappedBet)
                            } else {
                                // A nil value was successfully initialized from the QuerySnapshot,
                                // or the DocumentSnapshot was nil.
                                print("Document does not exist")
                            }
                        case .failure(let error):
                            // A Bet value could not be initialized from the QuerySnapshot.
                            print("Error decoding bet: \(error)")
                        }
                    }
                    completion(bets)
                }
            }
        betDashboardListeners.append(listener)
    }
    
    
    func addUserInvolvedBetsListener(completion: @escaping (_ bets: [Bet]) -> ()) {
        guard let uid = currentUser?.uid else { return }
        
        // Query for all bets user has taken a side on
        let listener = db.collection(K.Firestore.bets)
            .whereField(K.Firestore.acceptedUsers, arrayContains: uid)
            .order(by: K.Firestore.dateOpened, descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    // TODO: better error handling to display to user
                    print("Error getting documents: \(error)")
                } else {
                    var bets = [Bet]()
                    for document in querySnapshot!.documents {
                        let result = Result {
                            try document.data(as: Bet.self)
                        }
                        switch result {
                        case .success(let bet):
                            if let unwrappedBet = bet {
                                // Successfully initialized a Bet value from QuerySnapshot
                                // Add bet to bets array.
                                bets.append(unwrappedBet)
                            } else {
                                // A nil value was successfully initialized from the QuerySnapshot,
                                // or the DocumentSnapshot was nil.
                                print("Document does not exist")
                            }
                        case .failure(let error):
                            // A Bet value could not be initialized from the QuerySnapshot.
                            print("Error decoding bet: \(error)")
                        }
                    }
                    completion(bets)
                }
            }
        betDashboardListeners.append(listener)
    }
    
    func initFetchOtherBets(completion: @escaping (_ bets: [Bet]) -> ()) {
        guard let uid = currentUser?.uid else { return }
        
        // Query for other bets around the platform where user is not involved.
        // TODO: As app grows, need to limit query to FRIENDS ONLY
        otherBetQuery = db.collection(K.Firestore.bets)
            // Can't query for fields NOT containing current UID, so have to just pull a bunch of bets and filter client side :(
            .order(by: K.Firestore.dateOpened, descending: true)
            .limit(to: 15)
        
        otherBetQuery?.getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                // TODO: better error handling to display to user
                print("Error getting documents: \(error)")
            } else {
                var bets = [Bet]()
                self?.lastBet = querySnapshot!.documents.last // store last bet for next paginated query
                for document in querySnapshot!.documents {
                    let result = Result {
                        try document.data(as: Bet.self)
                    }
                    switch result {
                    case .success(let bet):
                        if let unwrappedBet = bet {
                            // Successfully initialized a Bet value from QuerySnapshot
                            // Add bet to bets array if current user not involved.
                            if !unwrappedBet.allUsers.contains(uid) {
                                bets.append(unwrappedBet)
                            }
                        } else {
                            // A nil value was successfully initialized from the QuerySnapshot,
                            // or the DocumentSnapshot was nil.
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        // A Bet value could not be initialized from the QuerySnapshot.
                        print("Error decoding bet: \(error)")
                    }
                }
                completion(bets)
            }
        }
    }
    
    func fetchAdditionalBets(completion: @escaping (_ bets: [Bet]) -> ()) {
        guard let uid = currentUser?.uid,
              let query = otherBetQuery,
              let bet = lastBet else { return }
        
        otherBetQuery = query.start(afterDocument: bet) // store new query in class property for next query
        
        otherBetQuery?.getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                // TODO: better error handling to display to user
                print("Error getting documents: \(error)")
            } else {
                var bets = [Bet]()
                self?.lastBet = querySnapshot!.documents.last // store last bet for next paginated query
                for document in querySnapshot!.documents {
                    let result = Result {
                        try document.data(as: Bet.self)
                    }
                    switch result {
                    case .success(let bet):
                        if let unwrappedBet = bet {
                            // Successfully initialized a Bet value from QuerySnapshot
                            // Add bet to bets array if current user not involved.
                            if !unwrappedBet.allUsers.contains(uid) {
                                bets.append(unwrappedBet)
                            }
                        } else {
                            // A nil value was successfully initialized from the QuerySnapshot,
                            // or the DocumentSnapshot was nil.
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        // A Bet value could not be initialized from the QuerySnapshot.
                        print("Error decoding bet: \(error)")
                    }
                }
                completion(bets)
            }
        }
    }
    
    func deleteBet(withBetID betID: BetID) {
        db.collection(K.Firestore.bets).document(betID).delete { error in
            if let error = error {
                print("Error deleting bet: \(error)")
            }
        }
    }
    
    // MARK:- Friend CRUD
    func addFriendsListener(completion: @escaping (_ friends: [FriendSnippet]) -> ()) {
        // Check that there isn't already a friends listener
        guard let uid = currentUser?.uid,
              friendsListener == nil else { return }
        
        // Query for all documents in user's friend subcollection
        friendsListener = db.collection(K.Firestore.users)
            .document(uid)
            .collection(K.Firestore.friends)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                var snippets = [FriendSnippet]()
                if let error = error {
                    // TODO: better error handling
                    print("Error fetching friends from current user's friend subcollection: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let result = Result {
                            try document.data(as: FriendSnippet.self)
                        }
                        switch result {
                        case .success(let snippet):
                            if let snippet = snippet {
                                // Successfully decoded a snippet. Append to array.
                                snippets.append(snippet)
                            } else {
                                print("Document from friend listener does not exist")
                            }
                        case .failure(let error):
                            print("Error decoding snippet \(document.documentID) for friends list: \(error)")
                        }
                    }
                    self?.friends = snippets
                    completion(snippets)
                }
            }
    }
    
    func addAllUserListener(completion: @escaping (_ friends: [FullFriend]) -> ()) {
        // Listen to all users to provide up to date pool for user to search from.
        // Check that there isn't already a listener for all users
        guard let uid = currentUser?.uid,
              allUserListener == nil else { return }
        
        // Query to exclude current user.
        allUserListener = db.collection(K.Firestore.users)
            .whereField(K.Firestore.uid, notIn: [uid])
            .addSnapshotListener { (querySnapshot, error) in
                var potentialFriends = [FullFriend]()
                if let error = error {
                    print("Error fetching user documents for friend search: \(error)")
                    // TODO: Better error handling
                } else {
                    for document in querySnapshot!.documents {
                        let result = Result {
                            try document.data(as: FullFriend.self)
                        }
                        switch result {
                        case .success(let user):
                            if let user = user {
                                // If successful, add to array of users for search
                                potentialFriends.append(user)
                            } else {
                                print("Document from user listener does not exist")
                            }
                        case .failure(let error):
                            print("Error decoding user \(document.documentID) for friend search: \(error)")
                        }
                    }
                    completion(potentialFriends)
                }
            }
    }
    
    func addFriend(_ friend: FullFriend, completion: (() -> ())?) {
        guard let user = currentUser else { return }
        let currentUserSnippet = FriendSnippet(fromCurrentUser: user)
        let friendSnippet = FriendSnippet(fromFriend: friend)
            
        let userRef = db.collection(K.Firestore.users).document(user.uid)
        do {
            // Add friend to current user's friend list
            try userRef.collection(K.Firestore.friends)
                .document(friend.uid)
                .setData(from: friendSnippet)
            
            // Increment friend counter
            userRef.updateData([
                K.Firestore.numFriends: FieldValue.increment(Int64(1))
            ])
        } catch let error {
            // TODO: better error handling
            print("Error writing friend \(friend.uid) \n to user \(user.uid): \n \(error)")
            return
        }
        
        let friendRef = db.collection(K.Firestore.users).document(friend.uid)
        do {
            // Add current user to friend's friend list
            try friendRef.collection(K.Firestore.friends)
                .document(user.uid)
                .setData(from: currentUserSnippet)
            
            // Increment friend counter
            friendRef.updateData([
                K.Firestore.numFriends: FieldValue.increment(Int64(1))
                ])
        } catch let error {
            // TODO: better error handling
            print("Error writing friend \(user.uid) \n to user \(friend.uid): \n \(error)")
            return
        }
        completion?()
    }
    
    func getFriend(withUID uid: UID, completion: @escaping (_ friend: FullFriend) -> ()) {
        db.collection(K.Firestore.users)
            .document(uid)
            .getDocument { (document, error) in
                if let error = error {
                    print("Error retrieving friend \(uid): \(error)")
                } else {
                    let result = Result {
                        try document?.data(as: FullFriend.self)
                    }
                    switch result {
                    case .success(let friend):
                        if let friend = friend {
                            // Successfully initialized a Friend value from QuerySnapshot
                            completion(friend)
                        } else {
                            // A nil value was successfully initialized from the QuerySnapshot,
                            // or the DocumentSnapshot was nil.
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        // A Friend value could not be initialized from the QuerySnapshot.
                        print("Error decoding friend with uid \(uid): \(error)")
                    }
                }
            }
    }
    
    func removeFriend(withUID friendUID: UID, completion: @escaping(_ friend: FullFriend) -> ()) {
        // It's not you, it's me...
        guard let user = currentUser else { return }
        
        // Delete friend from current user's friend list then decrement friend count
        let userRef = db.collection(K.Firestore.users).document(user.uid)
        userRef.collection(K.Firestore.friends).document(friendUID).delete { error in
            if let error = error {
                print("Error deleting \(friendUID) from \(user.uid)'s friend list: \(error)")
            }
        }
        userRef.updateData([
            K.Firestore.numFriends: FieldValue.increment(Int64(-1))
        ])
        
        // Delete current user from (ex-)friend's friend list. So sad.
        let friendRef = db.collection(K.Firestore.users).document(friendUID)
        friendRef.collection(K.Firestore.friends).document(user.uid).delete { [weak self] error in
            if let error = error {
                print("Error deleting \(user.uid) from \(friendUID)'s friend list: \(error)")
            } else {
                // Pass back updated friend object
                self?.getFriend(withUID: friendUID, completion: completion)
            }
            
        }
    }
    
    // MARK:- Clean-up
    func logOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        unsubscribeAllSnapshotListeners()
        currentUser = nil
    }
    
    func unsubscribeAllSnapshotListeners() {
        // To be called at logout
        // Remember to include snapshot unsubs here as you add them elsewhere!
        userListeners.forEach { $0.remove() }
        userListeners = []
        betDashboardListeners.forEach { $0.remove() }
        betDashboardListeners = []
        friendsListener?.remove()
        friendsListener = nil
        allUserListener?.remove()
        allUserListener = nil
    }
    
}


