//
//  Bet.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/7/20.
//

import Foundation

enum BetType: String, Codable {
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
    var betID: String?
    let title: String
    var line: Double?
    let team1: String?
    let team2: String?
    private(set) var invitedUsers = Set<String>() // UIDs
    private(set) var side1Users = Set<String>() // UIDs
    private(set) var side2Users = Set<String>() // UIDs
    private(set) var allUsers = Set<String>() // UIDs
    private(set) var acceptedUsers = Set<String>() // UIDs
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
    
    mutating func perform(action: BetUserAction, with uid: String) {
        guard !isFinished else { return }
        
        switch action {
        case .invite:
            invitedUsers.insert(uid)
            allUsers.insert(uid)
        case .uninvite:
            invitedUsers.remove(uid)
            allUsers.remove(uid)
        case .addToSide1:
            if invitedUsers.contains(uid) && !side2Users.contains(uid) {
                invitedUsers.remove(uid)
                side1Users.insert(uid)
                acceptedUsers.insert(uid)
            }
        case .addToSide2:
            if invitedUsers.contains(uid) && !side1Users.contains(uid) {
                invitedUsers.remove(uid)
                side2Users.insert(uid)
                acceptedUsers.insert(uid)
            }
        case .removeFromSide:
            side1Users.remove(uid)
            side2Users.remove(uid)
            allUsers.remove(uid)
            acceptedUsers.remove(uid)
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
