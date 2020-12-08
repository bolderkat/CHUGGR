//
//  User.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/21/20.
//

import Foundation

struct Drinks: Codable {
    var beers: Int
    var shots: Int
}

enum UserAction {
    case add
    case delete
}

protocol User {
    var uuid: String { get }
    var email: String { get }
    var firstName: String { get }
    var lastName: String { get }
    var fullName: String { get }
    var bio: String { get }
    var numBets: Int { get set }
    var numFriends: Int { get set }
    var betsWon: Int { get set }
    var betsLost: Int { get set }
    var drinksGiven: Drinks { get set }
    var drinksReceived: Drinks { get set }
    var drinksOutstanding: Drinks { get set }
    
    mutating func modifyBetCount(with: UserAction)
    mutating func modifyFriendCount(with: UserAction)
    mutating func logFinishedBet(isWinner: Bool, with drinks: Drinks)
}
  
