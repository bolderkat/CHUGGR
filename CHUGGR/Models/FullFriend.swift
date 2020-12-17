//
//  Friend.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/9/20.
//

import Foundation

struct FullFriend: Friend, Codable {
    let uid: UID
    let firstName: String
    let lastName: String
    let userName: String
    let bio: String
    let profilePic: String // TODO: implement actual profile pics
    private(set) var numBets: Int
    private(set) var numFriends: Int
    private(set) var betsWon: Int
    private(set) var betsLost: Int
    private(set) var drinksGiven: Drinks
    private(set) var drinksReceived: Drinks
    private(set) var drinksOutstanding: Drinks
    
    
    mutating func modifyBetCount(with action: UserAction) {
        switch action {
        case .add:
            numBets += 1
        case .delete:
            numBets -= 1
        }
    }
    
    mutating func modifyFriendCount(with action: UserAction) {
        switch action {
        case .add:
            numFriends += 1
        case .delete:
            numFriends -= 1
        }
    }
    
    mutating func logFinishedBet(isWinner: Bool, with drinks: Drinks) {
        if isWinner {
            drinksGiven.beers += drinks.beers
            drinksGiven.shots += drinks.shots
            betsWon += 1
        } else {
            drinksReceived.beers += drinks.beers
            drinksReceived.beers += drinks.shots
            betsLost += 1
            // TODO: Increment drinksOutstanding when video uploading is added to app.
            
        }
    }
}
