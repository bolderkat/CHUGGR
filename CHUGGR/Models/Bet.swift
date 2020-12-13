//
//  Bet.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/7/20.
//

import Foundation

typealias BetID = String

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
    private(set) var betID: BetID?
    let title: String
    var line: Double?
    let team1: String?
    let team2: String?
    private(set) var invitedUsers = [UID: String]() // UID and firstName
    private(set) var side1Users = [UID: String]()
    private(set) var side2Users = [UID: String]()
    private(set) var allUsers = Set<String>()
    private(set) var acceptedUsers = Set<String>()
    var stake: Drinks
    let dateOpened: TimeInterval
    var dueDate: TimeInterval
    private(set) var isFinished = false
    private(set) var winner: Side?
    private(set) var dateFinished: TimeInterval? = nil
    
    mutating func setBetID(withID id: String) {
        self.betID = id
    }
    
    mutating func closeBetWith(winningSide: Side) {
        guard !isFinished else { return }
        winner = winningSide
        isFinished = true
        dateFinished = Date().timeIntervalSince1970
    }
    
    mutating func perform(action: BetUserAction, withID uid: UID, firstName name: String) {
        guard !isFinished else { return }
        
        switch action {
        case .invite:
            invitedUsers[uid] = name
            allUsers.insert(uid)
        case .uninvite:
            invitedUsers[uid] = nil
            allUsers.remove(uid)
        case .addToSide1:
            if invitedUsers[uid] != nil && side2Users[uid] == nil {
                invitedUsers[uid] = nil
                side1Users[uid] = name
                acceptedUsers.insert(uid)
            }
        case .addToSide2:
            if invitedUsers[uid] != nil && side1Users[uid] == nil {
                invitedUsers[uid] = nil
                side2Users[uid] = name
                acceptedUsers.insert(uid)
            }
        case .removeFromSide:
            side1Users[uid] = nil
            side2Users[uid] = nil
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
