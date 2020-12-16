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
    private var userListeners: [ListenerRegistration] = []
    private var betDashboardListeners: [ListenerRegistration] = []
    private var allUserListener: ListenerRegistration?
    
    // Storing bet queries and last bet of each query for paginated population of infinitely scrolling table view
    private var otherBetQuery: Query?
    private var lastBet: QueryDocumentSnapshot?
    
    // MARK:- User CRUD
    func createNewUser(
        firstName: String,
        lastName: String,
        screenName: String,
        bio: String,
        ifScreenNameTaken: @escaping (() -> ()),
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
            screenName: screenName,
            bio: bio,
            numBets: 0,
            numFriends: 0,
            betsWon: 0, betsLost: 0,
            drinksGiven: emptyDrinks,
            drinksReceived: emptyDrinks,
            drinksOutstanding: emptyDrinks,
            recentFriends: [String]()
        )
        
        
        // Check if screen name is already in use
        let docRef = db.collection(K.Firestore.users).whereField(K.Firestore.screenName, isEqualTo: screenName)
        docRef.getDocuments { [weak self] (document, error) in
            if let error = error {
                print("Error completing query for existing username: \(error)")
            } else {
                if document?.count == 0 {
                    // No existing user found with that screen name. Proceed with user write.
                    self?.writeNewUser(user, completion: completion)
                } else {
                    // Existing user found with specified screen name
                    // TODO: Verify if this is where to call main thread??
                        ifScreenNameTaken()
                }
            }
        }
    }
    
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
    
    // MARK:- Friend CRUD
    func addAllUserListener( completion: @escaping (_ friends: [Friend]) -> ()) {
        guard let uid = currentUser?.uid,
              allUserListener == nil else { return } // Check that there isn't already a listener for all users
        
        // Query to exclude current user.
        allUserListener = db.collection(K.Firestore.users)
            .whereField(K.Firestore.uid, notIn: [uid])
            .addSnapshotListener { (querySnapshot, error) in
                var potentialFriends = [Friend]()
                if let error = error {
                    print("Error fetching user documents for friend search: \(error)")
                    // TODO: Better error handling
                } else {
                    for document in querySnapshot!.documents {
                        let result = Result {
                            try document.data(as: Friend.self)
                        }
                        switch result {
                        case .success(let user):
                            if let user = user {
                                // If successful, add to array of users for search
                                potentialFriends.append(user)
                            } else {
                                print("Document does not exist")
                            }
                        case .failure(let error):
                            print("Error decoding user for friend search: \(error)")
                        }
                    }
                    completion(potentialFriends)
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
        allUserListener = nil
    }
    
}

