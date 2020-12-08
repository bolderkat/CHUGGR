//
//  Bet.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/7/20.
//

import Foundation

enum BetType: Int, Codable {
    case spread
    case moneyline
    case event
}

enum Side: Int, Codable {
    case one = 0
    case two
}

enum BetUserAction {
    case invite
    case uninvite
    case addToSide1
    case addToSide2
    case removeFromSide
}

struct Bet: Codable {
    let type: BetType
    let title: String
    var line: Double?
    let team1: String?
    let team2: String?
    private(set) var invitedUsers = Set<String>() // UUIDs
    private(set) var side1Users = Set<String>() // UUIDs
    private(set) var side2Users = Set<String>() // UUIDs
    var allUsers: Set<String> {
        invitedUsers.union(side1Users).union(side2Users)
    }
    var stake: Drinks
    let dateOpened: TimeInterval
    var dueDate: TimeInterval
    private(set) var isFinished = false
    private(set) var winner: Side?
    private(set) var dateFinished: TimeInterval? = nil
    
    mutating func closeBetWith(winningSide: Side) {
        guard !isFinished else { return }
        winner = winningSide
        isFinished = true
        dateFinished = Date().timeIntervalSince1970
    }
    
    mutating func perform(action: BetUserAction, with uuid: String) {
        guard !isFinished else { return }
        
        switch action {
        case .invite:
            invitedUsers.insert(uuid)
        case .uninvite:
            invitedUsers.remove(uuid)
        case .addToSide1:
            if invitedUsers.contains(uuid) && !side2Users.contains(uuid) {
                invitedUsers.remove(uuid)
                side1Users.insert(uuid)
            }
        case .addToSide2:
            if invitedUsers.contains(uuid) && !side1Users.contains(uuid) {
                invitedUsers.remove(uuid)
                side2Users.insert(uuid)
            }
        case .removeFromSide:
            side1Users.remove(uuid)
            side2Users.remove(uuid)
        }
    }
}


struct CodableBet: Codable {
    let type: BetType
    let title: String
    var line: Double?
    let team1: String?
    let team2: String?
    private(set) var invitedUsers = Set<String>() // UUIDs
    private(set) var side1Users = Set<String>() // UUIDs
    private(set) var side2Users = Set<String>() // UUIDs
    var allUsers: Set<String> {
        invitedUsers.union(side1Users).union(side2Users)
    }
//    var stake: Drinks
    let dateOpened: TimeInterval
    var dueDate: TimeInterval
    private(set) var isFinished = false
    private(set) var winner: Side?
    private(set) var dateFinished: TimeInterval? = nil
}
