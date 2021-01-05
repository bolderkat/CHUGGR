//
//  MockFirestoreHelper.swift
//  CHUGGR
//
//  Created by Daniel Luo on 1/4/21.
//

import Foundation

class MockFirestoreHelper: FirestoreHelping {
    private(set) var currentUser: CurrentUser?
    private(set) var friends: [FriendSnippet] = []
    private(set) var allUsers: [FullFriend] = []
    private(set) var involvedBets: [Bet] = []
    var currentUserDidChange: ((CurrentUser) -> ())? // for use by profile view ONLY
    
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
    var voidCompletion: (() -> ())!
    var onUserDocNotFound: (() -> ())!
    var voidFailure: (() -> ())!
    var betCompletion: ((Bet) -> ())!
    var betsArrayCompletion: (([Bet]) -> ())!
    var optionalBetCompletion: ((Bet?) -> ())!
    var messagesCompletion: (([Message]) -> ())!
    var friendSnippetCompletion: (([FriendSnippet]) -> ())!
    var friendCompletion: ((FullFriend) -> ())!
    

    
    // MARK:- User CRUD
    func createNewUser(
        firstName: String,
        lastName: String,
        userName: String,
        bio: String,
        ifUserNameTaken: @escaping (() -> ()),
        completion: (() -> ())?
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
        isUserCreated = true
        writeNewUser(user, completion: completion)
    }
    
    func writeNewUser(_ user: CurrentUser, completion: (() -> ())?) {
        isUserWrittenToDB = true
        readUserOnLogin(with: user.uid, completion: completion, onUserDocNotFound: nil, failure: nil)
    }
    
    func readUserOnLogin(
        with uid: String,
        completion: (() -> ())?,
        onUserDocNotFound: (() -> ())?,
        failure: (() -> ())?
    ) {
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
    
    func readBet(withBetID id: BetID?, completion: @escaping (Bet) -> ()) {
        if id != nil {
            betReads += 1
            betCompletion = completion
        }
    }
    
    func updateBet(_ bet: Bet, completion: ((Bet?) -> ())?) {
        betUpdates += 1
        
        if completion != nil {
            optionalBetCompletion = completion
        }
    }
    
    func deleteBet(_ bet: Bet) {
        betDeletes += 1
    }
    
    func closeBet(_ bet: Bet, betAlreadyClosed: @escaping ((Bet?) -> ()), completion: (() -> ())?) {
        if betCloses == 0 {
            betCloses += 1
        } else {
            optionalBetCompletion = betAlreadyClosed
        }
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
    func addBetDetailListener(with id: BetID, in tab: Tab, completion: @escaping (Bet) -> ()) {
        betDetailListeners += 1
        betCompletion = completion
    }
    
    // MARK:- Bet chat message methods
    func sendMessage(for bet: BetID, with body: String) {
        messagesSent += 1
    }
    
    func addBetMessageListener(with id: BetID, in tab: Tab, completion: @escaping ([Message]) -> ()) {
        messageListeners += 1
        messagesCompletion = completion
    }
    
    // MARK:- Bet dashboard methods
    func addUserInvolvedBetsListener(completion: @escaping ([Bet]) -> ()) {
        userInvolvedBetsListeners += 1
        betsArrayCompletion = completion
    }
    
    func initFetchOtherBets(completion: @escaping ([Bet]) -> ()) {
        initOtherBetFetches += 1
        betsArrayCompletion = completion
    }
    
    func fetchAdditionalBets(completion: @escaping ([Bet]) -> ()) {
        subsequentOtherBetFetches += 1
        betsArrayCompletion = completion
    }
    
    // MARK:- Friend/Profile bet methods
    func addFriendActiveBetListener(for user: UID, completion: @escaping ([Bet]) -> ()) {
        friendActiveBetListeners += 1
        betsArrayCompletion = completion
    }
    
    func addFriendOutstandingBetListener(for user: UID, completion: @escaping ([Bet]) -> ()) {
        friendOutstandingBetListeners += 1
        betsArrayCompletion = completion
    }
    
    func initFetchPastBets(for user: UID, completion: @escaping ([Bet]) -> ()) {
        initPastBetFetches += 1
        betsArrayCompletion = completion
    }
    
    func fetchAdditionalPastBets(for user: UID, completion: @escaping ([Bet]) -> ()) {
        subsequentPastBetFetches += 1
        betsArrayCompletion = completion
    }
    
    // MARK:- Friend CRUD
    func addFriendsListener(completion: @escaping ([FriendSnippet]) -> ()) {
        friendListeners += 1
        friendSnippetCompletion = completion
    }
    
    func addAllUserListener(completion: @escaping () -> ()) {
        allUserListeners += 1
        voidCompletion = completion
    }
    
    func addFriend(_ friend: FullFriend, completion: (() -> ())?) {
        friendAdds += 1
        if completion != nil {
            voidCompletion = completion
        }
    }
    
    func getFriend(withUID uid: UID, completion: @escaping (FullFriend) -> ()) {
        friendFetches += 1
        friendCompletion = completion
    }
    
    func setFriendDetailListener(with uid: UID, completion: @escaping (FullFriend) -> ()) {
        friendDetailListeners += 1
        friendCompletion = completion
    }
    
    func removeFriend(withUID friendUID: UID, completion: @escaping () -> ()) {
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
