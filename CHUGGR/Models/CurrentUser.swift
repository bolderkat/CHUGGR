//
//  CurrentUser.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/9/20.
//

import Foundation

class CurrentUser: User, Codable {
    let uid: String
    private(set) var email: String
    private(set) var firstName: String
    private(set) var lastName: String
    private(set) var userName: String
    private(set) var bio: String
    private(set) var profilePic: String = "" // TODO: implement actual profile pics
    private(set) var numBets: Int
    private(set) var numFriends: Int
    private(set) var betsWon: Int
    private(set) var betsLost: Int
    private(set) var drinksGiven: Drinks
    private(set) var drinksReceived: Drinks
    private(set) var drinksOutstanding: Drinks
    private(set) var recentFriends: [String] // UIDs
    
    init(
        uid: String,
        email: String,
        firstName: String,
        lastName: String,
        userName: String,
        bio: String,
        numBets: Int,
        numFriends: Int,
        betsWon: Int,
        betsLost: Int,
        drinksGiven: Drinks,
        drinksReceived: Drinks,
        drinksOutstanding: Drinks,
        recentFriends: [String]
    ) {
        self.uid = uid
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
        self.bio = bio
        self.numBets = numBets
        self.numFriends = numFriends
        self.betsWon = betsWon
        self.betsLost = betsLost
        self.drinksGiven = drinksGiven
        self.drinksReceived = drinksReceived
        self.drinksOutstanding = drinksOutstanding
        self.recentFriends = recentFriends
    }
    
    func updateProfileFields(
        firstName: String,
        lastName: String,
        userName: String,
        bio: String
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
        self.bio = bio
    }
    
    func modifyBetCount(with action: UserAction) {
        switch action {
        case .add:
            numBets += 1
        case .delete:
            numBets -= 1
        }
    }
    
    func modifyFriendCount(with action: UserAction) {
        switch action {
        case .add:
            numFriends += 1
        case .delete:
            numFriends -= 1
        }
    }
    
    func logFinishedBet(isWinner: Bool, with drinks: Drinks) {
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
    
    func updateRecentFriends(with friends: [String]) {
        self.recentFriends = friends
    }
}
