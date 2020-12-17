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
            checkFriendStatus()
            updateVCLabels?()
        }
    }
    private(set) var isAlreadyFriends = false {
        didSet {
            // Disable/enable add friend button based on friend status
            doesButtonTriggerAddMethod = !isAlreadyFriends
        }
    }
    // Flag to prevent fast 2x button press triggering add method twice
    private var doesButtonTriggerAddMethod = true {
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
        // Check if other user is already friend of current user.
        if firestoreHelper.friends.contains(where: { $0.uid == self.friend.uid }) {
            isAlreadyFriends = true
        } else {
            isAlreadyFriends = false
        }
    }
    
    func addFriend() {
        // TODO: eventually we want to implement friend requests instead of just doing a unilateral mutual add right away. But for now... gotta push this MVP out!
        
        // Check if this is a valid friend add (i.e., not already friends)
        if !isAlreadyFriends, doesButtonTriggerAddMethod {
            //create friend documents and update client-side friend detail data
            firestoreHelper.addFriend(friend) { [weak self] in
                self?.checkFriendStatus()
                self?.updateFriendData()
            }
        }
        doesButtonTriggerAddMethod = false
    }
    
    func removeFriend() {
        firestoreHelper.removeFriend(withUID: friend.uid) { [weak self] friend in
            self?.friend = friend
        }
    }
    
}
