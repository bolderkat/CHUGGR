//
//  User.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/21/20.
//

import Foundation

enum UserAction {
    case add
    case delete
}

typealias UID = String

protocol User {
    mutating func modifyBetCount(with action: UserAction)
    mutating func modifyFriendCount(with action: UserAction)
    mutating func logFinishedBet(isWinner: Bool, with drinks: Drinks)
}
  
