//
//  FirestoreHelping.swift
//  CHUGGR
//
//  Created by Daniel Luo on 1/4/21.
//

import Foundation

protocol FirestoreHelping {
    
    var currentUser: CurrentUser? { get }
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
        ifUserNameTaken: @escaping (() -> ()),
        completion: (() -> ())?
    )
    
    func writeNewUser(_ user: CurrentUser, completion: (() ->())?)
    
    func readUserOnLogin(
        with uid: String,
        completion: (() -> ())?,
        onUserDocNotFound: (() -> ())?,
        failure: (() -> ())?
    )
    
    func addCurrentUserListener(with uid: String)
    
    // MARK:- Bet CRUD
    func writeNewBet(bet: inout Bet) -> BetID?
    func readBet(withBetID id: BetID?, completion: @escaping (_ bet: Bet) -> ())
    func updateBet(_ bet: Bet, completion: ((Bet?) -> ())?)
    func deleteBet(_ bet: Bet)
    func closeBet(_ bet: Bet, betAlreadyClosed: @escaping ((Bet?) -> ()), completion: (() -> ())?)
    
    // MARK:- Bet counter increments
    func updateBetCounter(increasing: Bool)
    func updateCountersOnBetClose(with bet: Bet?)
    func updateCountersOnBetFulfillment(with bet: Bet?)

    // MARK:- Bet Detail methods
    func addBetDetailListener(with id: BetID, in tab: Tab, completion: @escaping (_ bet: Bet) -> ())
    
    // MARK:- Bet chat message methods
    func sendMessage(for bet: BetID, with body: String)
    func addBetMessageListener(with id: BetID, in tab: Tab, completion: @escaping (_ messages: [Message]) -> ())
    
    // MARK:- Bet dashboard methods
    func addUserInvolvedBetsListener(completion: @escaping (_ bets: [Bet]) -> ())
    func initFetchOtherBets(completion: @escaping (_ bets: [Bet]) -> ())
    func fetchAdditionalBets(completion: @escaping (_ bets: [Bet]) -> ())
    
    // MARK:- Friend/Profile bet methods
    func addFriendActiveBetListener(for user: UID, completion: @escaping (_ bets: [Bet]) -> ())
    func addFriendOutstandingBetListener(for user: UID, completion: @escaping (_ bets: [Bet]) -> ())
    func initFetchPastBets(for user: UID, completion: @escaping (_ bets: [Bet]) -> ())
    func fetchAdditionalPastBets(for user: UID, completion: @escaping (_ bets: [Bet]) -> ())
    
    // MARK:- Friend CRUD
    func addFriendsListener(completion: @escaping (_ friends: [FriendSnippet]) -> ())
    func addAllUserListener(completion: @escaping () -> ())
    func addFriend(_ friend: FullFriend, completion: (() -> ())?)
    func getFriend(withUID uid: UID, completion: @escaping (_ friend: FullFriend) -> ())
    func setFriendDetailListener(with uid: UID, completion: @escaping (_ friend: FullFriend) -> ())
    func removeFriend(withUID friendUID: UID, completion: @escaping () -> ())
    
    // MARK:- Clean-up
    func logOut()
    func cleanUp()
    func removeBetDetailListener(for tab: Tab)
    func removeAllBetDetailListeners()
    func clearFriendDetail()
    func unsubscribeAllSnapshotListeners()
}

