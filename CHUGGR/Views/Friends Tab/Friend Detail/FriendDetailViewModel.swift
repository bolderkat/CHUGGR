//
//  FriendDetailViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/16/20.
//

import Foundation

class FriendDetailViewModel {
    private let firestoreHelper: FirestoreHelper
    private(set) var friend: FullFriend {
        didSet {
            updateVCLabels?()
        }
    }
    
    private(set) var isAlreadyFriends = false {
        didSet {
            setVCForFriendStatus?()
        }
    }
    
    var updateVCLabels: (() -> ())?
    var setVCForFriendStatus: (() -> ())?

    
    init(firestoreHelper: FirestoreHelper, friend: FullFriend) {
        self.firestoreHelper = firestoreHelper
        self.friend = friend
    }
    
    func updateFriendData() {
        firestoreHelper.getFriend(withUID: friend.uid) { [weak self] friend in
            self?.friend = friend
        }
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
        
        // Make sure friend docs do not already exist, indicating they are already friends
        firestoreHelper.checkFriendStatus(
            with: friend,
            completionIfFalse: { [weak self] in
                self?.addFriend()
            },
            completionIfTrue: nil)
    }
    
    func addFriend() {
        // If verified to be a valid friend add, create friend documents and update client-side friend data
        firestoreHelper.addFriend(friend) { [weak self] in
            self?.checkFriendStatus()
            self?.updateFriendData()
        }
    }
}
