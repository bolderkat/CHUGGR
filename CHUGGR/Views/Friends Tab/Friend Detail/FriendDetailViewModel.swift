//
//  FriendDetailViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/16/20.
//

import Foundation

class FriendDetailViewModel {
    private let firestoreHelper: FirestoreHelper
    let friend: FullFriend
    private(set) var isAlreadyFriends = false {
        didSet {
            setVCForFriendStatus?()
        }
    }
    
    var setVCForFriendStatus: (() -> ())?

    
    init(firestoreHelper: FirestoreHelper, friend: FullFriend) {
        self.firestoreHelper = firestoreHelper
        self.friend = friend
    }
    
    func getDrinksString(forStat stat: DrinkStatType) -> String? {
        switch stat {
        case .given:
            return "\(friend.drinksGiven.beers) 🍺 \(friend.drinksGiven.shots) 🥃"
        case .received:
            return "\(friend.drinksReceived.beers) 🍺 \(friend.drinksReceived.shots) 🥃"
        case .outstanding:
            return "\(friend.drinksOutstanding.beers) 🍺 \(friend.drinksOutstanding.shots) 🥃"
        }
    }
    
    func checkFriendStatus() {
        firestoreHelper.checkFriendStatus(
            with: friend,
            completionIfFalse: { [weak self] in
                self?.isAlreadyFriends = false
            },
            completionIfTrue: { [weak self] in
                self?.isAlreadyFriends = true
            }
        )
    }
    
    func addFriendIfSafe() {
        // TODO: eventually we want to implement friend requests instead of just doing a unilateral mutual add right away. But for now... gotta push this MVP out!
        firestoreHelper.checkFriendStatus(
            with: friend,
            completionIfFalse: { [weak self] in
                self?.addFriend()
            },
            completionIfTrue: nil)
    }
    
    func addFriend() {
        firestoreHelper.addFriend(friend) { [weak self] in
            self?.checkFriendStatus()
        }
    }
}
