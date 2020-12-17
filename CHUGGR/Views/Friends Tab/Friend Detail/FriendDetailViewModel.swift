//
//  FriendDetailViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/16/20.
//

import Foundation

class FriendDetailViewModel {
    private let firestoreHelper: FirestoreHelper
    let friend: Friend
    
    init(firestoreHelper: FirestoreHelper, friend: Friend) {
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
}
