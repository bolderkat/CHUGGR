//
//  FirestoreHelping.swift
//  CHUGGR
//
//  Created by Daniel Luo on 1/4/21.
//

import Foundation

protocol FirestoreHelping {
    
    var currentUser: CurrentUser? { get }
    var currentUID: UID? { get }
    var friends: [FriendSnippet] { get }
    var allUsers: [FullFriend] { get }
    var involvedBets: [Bet] { get }
    var currentUserDidChange: ((CurrentUser) -> ())? { get set }
    
    // MARK:- User CRUD
    func createNewUser(
        firstName: String,
        lastName: String,
        userName: String,
        bio: String,
        ifUserNameTaken: @escaping (() -> Void),
        completion: (() -> Void)?
    )
    
    func writeNewUser(_ user: CurrentUser, completion: (() ->())?)
    
    func readUserOnLogin(
        with uid: String,
        completion: (() -> Void)?,
        onUserDocNotFound: (() -> Void)?,
        failure: (() -> Void)?
    )
    
    func addCurrentUserListener(with uid: String)
    
    // MARK:- Bet CRUD
    func writeNewBet(bet: inout Bet) -> BetID?
    func readBet(withBetID id: BetID?, completion: @escaping (_ bet: Bet) -> Void)
    func updateBet(_ bet: Bet, completion: ((Bet?) -> Void)?)
    func deleteBet(_ bet: Bet)
    func closeBet(_ bet: Bet, betAlreadyClosed: @escaping ((Bet?) -> Void), completion: (() -> Void)?)
    
    // MARK:- Bet counter increments
    func updateBetCounter(increasing: Bool)
    func updateCountersOnBetClose(with bet: Bet?)
    func updateCountersOnBetFulfillment(with bet: Bet?)

    // MARK:- Bet Detail methods
    func addBetDetailListener(with id: BetID, in tab: Tab, completion: @escaping (_ bet: Bet) -> Void)
    
    // MARK:- Bet chat message methods
    func sendMessage(for bet: BetID, with body: String)
    func addBetMessageListener(with id: BetID, in tab: Tab, completion: @escaping (_ messages: [Message]) -> Void)
    
    // MARK:- Bet dashboard methods
    func addUserInvolvedBetsListener(completion: @escaping () -> Void)
    func initFetchOtherBets(completion: @escaping (_ bets: [Bet]) -> Void)
    func fetchAdditionalBets(completion: @escaping (_ bets: [Bet]) -> Void)
    
    // MARK:- Friend/Profile bet methods
    func addFriendActiveBetListener(for user: UID, completion: @escaping (_ bets: [Bet]) -> Void)
    func addFriendOutstandingBetListener(for user: UID, completion: @escaping (_ bets: [Bet]) -> Void)
    func initFetchPastBets(for user: UID, completion: @escaping (_ bets: [Bet]) -> Void)
    func fetchAdditionalPastBets(for user: UID, completion: @escaping (_ bets: [Bet]) -> Void)
    
    // MARK:- Friend CRUD
    func addFriendsListener(completion: @escaping (_ friends: [FriendSnippet]) -> Void)
    func addAllUserListener(completion: @escaping () -> Void)
    func addFriend(_ friend: FullFriend, completion: (() -> Void)?)
    func getFriend(withUID uid: UID, completion: @escaping (_ friend: FullFriend) -> Void)
    func setFriendDetailListener(with uid: UID, completion: @escaping (_ friend: FullFriend) -> Void)
    func removeFriend(withUID friendUID: UID, completion: @escaping () -> Void)
    
    // MARK:- Clean-up
    func logOut(completion: (() -> Void)?)
    func cleanUp()
    func removeBetDetailListener(for tab: Tab)
    func removeAllBetDetailListeners()
    func clearFriendDetail()
    func unsubscribeAllSnapshotListeners()
}

