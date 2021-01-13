//
//  MockFirestoreHelper.swift
//  CHUGGR
//
//  Created by Daniel Luo on 1/4/21.
//

import Foundation

class MockFirestoreHelper: FirestoreHelping {
    var currentUser: CurrentUser? = CurrentUser(
        uid: "uid",
        email: "email",
        firstName: "firstName",
        lastName: "lastName",
        userName: "userName",
        bio: "bio",
        numBets: 0,
        numFriends: 0,
        betsWon: 0,
        betsLost: 0,
        drinksGiven: Drinks(beers: 0, shots: 0),
        drinksReceived: Drinks(beers: 0, shots: 0),
        drinksOutstanding: Drinks(beers: 0, shots: 0),
        recentFriends: [String]()
    )
    var sampleBets: [Bet] = []
    
    var friends: [FriendSnippet] {
        var friends = [FriendSnippet]()
        for friend in TestingData.friends {
            friends.append(FriendSnippet(fromFriend: friend))
        }
        return friends
    }
    
    private(set) var allUsers: [FullFriend] = []
    private(set) var involvedBets: [Bet] = []
    var currentUserDidChange: ((CurrentUser) -> Void)? // for use by profile view ONLY
    
    private(set) var isUserCreated = false
    private(set) var isUserWrittenToDB = false
    private(set) var isUserStoredFromDB = false
    private(set) var currentUserListeners = 0
    
    private(set) var newBetWrites = 0
    private(set) var betReads = 0
    private(set) var betUpdates = 0
    private(set) var betDeletes = 0
    private(set) var betCloses = 0
    private(set) var betUpdateIncrements = 0
    private(set) var betCloseIncrements = 0
    private(set) var betFulfillIncrements = 0
    private(set) var betDetailListeners = 0
    private(set) var messagesSent = 0
    private(set) var messageListeners = 0
    
    private(set) var userInvolvedBetsListeners = 0
    private(set) var initOtherBetFetches = 0
    private(set) var subsequentOtherBetFetches = 0
    
    private(set) var friendActiveBetListeners = 0
    private(set) var friendOutstandingBetListeners = 0
    
    private(set) var initPastBetFetches = 0
    private(set) var subsequentPastBetFetches = 0
    
    private(set) var friendListeners = 0
    private(set) var allUserListeners = 0
    private(set) var friendAdds = 0
    private(set) var friendFetches = 0
    private(set) var friendDetailListeners = 0
    private(set) var friendRemoves = 0
    
    // MARK:- Closures (named based on parameters)
    var voidCompletion: (() -> Void)!
    var onUserDocNotFound: (() -> Void)!
    var voidFailure: (() -> Void)!
    var betCompletion: ((Bet) -> Void)!
    var betsArrayCompletion: (([Bet]) -> Void)!
    var optionalBetCompletion: ((Bet?) -> Void)!
    var messagesCompletion: (([Message]) -> Void)!
    var friendSnippetCompletion: (([FriendSnippet]) -> Void)!
    var friendCompletion: ((FullFriend) -> Void)!
    

    
    // MARK:- User CRUD
    func createNewUser(
        firstName: String,
        lastName: String,
        userName: String,
        bio: String,
        ifUserNameTaken: @escaping (() -> Void),
        completion: (() -> Void)?
    ) {
        let emptyDrinks = Drinks(beers: 0, shots: 0)
        let user = CurrentUser(
            uid: "uid",
            email: "email",
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
        if userName == "takenUserName" {
            ifUserNameTaken()
            return
        } else {
            isUserCreated = true
            writeNewUser(user, completion: completion)
        }
    }
    
    func writeNewUser(_ user: CurrentUser, completion: (() -> Void)?) {
        isUserWrittenToDB = true
        readUserOnLogin(with: user.uid, completion: completion, onUserDocNotFound: nil, failure: nil)
    }
    
    func readUserOnLogin(
        with uid: String,
        completion: (() -> Void)?,
        onUserDocNotFound: (() -> Void)?,
        failure: (() -> Void)?
    ) {
        
        if uid == "nonexistentUser" {
            onUserDocNotFound?()
            return
        }
        
        if uid == "failedRead" {
            failure?()
            return
        }
        
        isUserStoredFromDB = true
        addCurrentUserListener(with: uid)
        let emptyDrinks = Drinks(beers: 0, shots: 0)
        currentUser = CurrentUser(
            uid: "uid",
            email: "email",
            firstName: "firstName",
            lastName: "lastName",
            userName: "userName",
            bio: "bio",
            numBets: 0,
            numFriends: 0,
            betsWon: 0, betsLost: 0,
            drinksGiven: emptyDrinks,
            drinksReceived: emptyDrinks,
            drinksOutstanding: emptyDrinks,
            recentFriends: [String]()
        )
        
        if completion != nil {
            voidCompletion = completion // store completion handler in MockFirestoreHandler property
        }
    }
    
    func addCurrentUserListener(with uid: String) {
        currentUserListeners += 1
    }
    
    // MARK:- Bet CRUD
    func writeNewBet(bet: inout Bet) -> BetID? {
        newBetWrites += 1
        bet.setBetID(withID: "betID")
        return bet.betID
    }
    
    func readBet(withBetID id: BetID?, completion: @escaping (Bet) -> Void) {
        if id != nil {
            betReads += 1
            betCompletion = completion
        }
    }
    
    func updateBet(_ bet: Bet, completion: ((Bet?) -> Void)?) {
        betUpdates += 1
        
        if completion != nil {
            optionalBetCompletion = completion
            completion?(bet)
        }
    }
    
    func deleteBet(_ bet: Bet) {
        betDeletes += 1
        updateBetCounter(increasing: false)
    }
    
    func closeBet(_ bet: Bet, betAlreadyClosed: @escaping ((Bet?) -> Void), completion: (() -> Void)?) {
        if bet.betID == "alreadyClosed" {
            optionalBetCompletion = betAlreadyClosed
            return
        } else {
            optionalBetCompletion = { bet in
                // do nothing
            }
        }
        
        betCloses += 1
        betUpdateIncrements += 1
        
        if completion != nil {
            voidCompletion = completion
        }
    }
    
    // MARK:- Bet counter increments
    func updateBetCounter(increasing: Bool) {
        let increment = increasing ? 1 : -1
        betUpdateIncrements += increment
    }
    
    func updateCountersOnBetClose(with bet: Bet?) {
        if bet != nil {
            betCloseIncrements += 1
        }
    }
    
    func updateCountersOnBetFulfillment(with bet: Bet?) {
        if bet != nil {
            betFulfillIncrements += 1
        }
    }
    
    // MARK:- Bet Detail methods
    func addBetDetailListener(with id: BetID, in tab: Tab, completion: @escaping (Bet) -> Void) {
        betDetailListeners += 1
        betCompletion = completion
    }
    
    // MARK:- Bet chat message methods
    func sendMessage(for bet: BetID, with body: String) {
        messagesSent += 1
    }
    
    func addBetMessageListener(with id: BetID, in tab: Tab, completion: @escaping ([Message]) -> Void) {
        messageListeners += 1
        messagesCompletion = completion
    }
    
    // MARK:- Bet dashboard methods
    func addUserInvolvedBetsListener(completion: @escaping ([Bet]) -> Void) {
        userInvolvedBetsListeners += 1
        betsArrayCompletion = completion
        let bets = sampleBets
            .filter { $0.allUsers.contains("uid") }
            .sorted { $0.dateOpened < $1.dateOpened }
        completion(bets)
        involvedBets = bets
    }
    
    func initFetchOtherBets(completion: @escaping ([Bet]) -> Void) {
        initOtherBetFetches += 1
        betsArrayCompletion = completion
        var bets = sampleBets
            .filter { !$0.allUsers.contains("uid") }
            .sorted { $0.dateOpened < $1.dateOpened }
        // Simulate Firestore query limit
        if bets.count == 3 {
            bets.remove(at: 2)
        }
        completion(bets)
    }
    
    func fetchAdditionalBets(completion: @escaping ([Bet]) -> Void) {
        subsequentOtherBetFetches += 1
        betsArrayCompletion = completion
        var bets = sampleBets
            .filter { !$0.allUsers.contains("uid") }
            .sorted { $0.dateOpened < $1.dateOpened }
        // Simulate subsequent Firestore query
        if bets.count == 3 {
            bets.remove(at: 0)
            bets.remove(at: 0)
        }
        completion(bets)

    }
    
    // MARK:- Friend/Profile bet methods
    func addFriendActiveBetListener(for user: UID, completion: @escaping ([Bet]) -> Void) {
        friendActiveBetListeners += 1
        betsArrayCompletion = completion
    }
    
    func addFriendOutstandingBetListener(for user: UID, completion: @escaping ([Bet]) -> Void) {
        friendOutstandingBetListeners += 1
        betsArrayCompletion = completion
    }
    
    func initFetchPastBets(for user: UID, completion: @escaping ([Bet]) -> Void) {
        initPastBetFetches += 1
        betsArrayCompletion = completion
    }
    
    func fetchAdditionalPastBets(for user: UID, completion: @escaping ([Bet]) -> Void) {
        subsequentPastBetFetches += 1
        betsArrayCompletion = completion
    }
    
    // MARK:- Friend CRUD
    func addFriendsListener(completion: @escaping ([FriendSnippet]) -> Void) {
        friendListeners += 1
        friendSnippetCompletion = completion
        completion(friends)
    }
    
    func addAllUserListener(completion: @escaping () -> Void) {
        allUserListeners += 1
        voidCompletion = completion
    }
    
    func addFriend(_ friend: FullFriend, completion: (() -> Void)?) {
        friendAdds += 1
        if completion != nil {
            voidCompletion = completion
        }
    }
    
    func getFriend(withUID uid: UID, completion: @escaping (FullFriend) -> Void) {
        friendFetches += 1
        friendCompletion = completion
        if let index = friends.firstIndex(where: { $0.uid == uid }) {
            completion(TestingData.friends[index])
        }
    }
    
    func setFriendDetailListener(with uid: UID, completion: @escaping (FullFriend) -> Void) {
        friendDetailListeners += 1
        friendCompletion = completion
    }
    
    func removeFriend(withUID friendUID: UID, completion: @escaping () -> Void) {
        friendRemoves += 1
        voidCompletion = completion
    }
    
    // MARK:- Clean-up
    func logOut() {
        cleanUp()
        unsubscribeAllSnapshotListeners()
    }
    
    func cleanUp() {
        isUserStoredFromDB = false
    }
    
    func removeBetDetailListener(for tab: Tab) {
        betDetailListeners -= 1
    }
    
    func removeAllBetDetailListeners() {
        betDetailListeners = 0
    }
    
    func clearFriendDetail() {
        friendOutstandingBetListeners -= 1
        friendActiveBetListeners -= 1
        friendDetailListeners -= 1
        
    }
    
    func unsubscribeAllSnapshotListeners() {
        currentUserListeners -= 1
        userInvolvedBetsListeners -= 1
        friendListeners -= 1
        allUserListeners -= 1
        clearFriendDetail()
        removeAllBetDetailListeners()
    }
    
    
}
