//
//  Bet.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/7/20.
//

import Foundation

typealias BetID = String
enum BetInvolvementType {
    case accepted
    case invited
    case uninvolved
    case outstanding
    case closed
}
enum BetType: String, Codable, CaseIterable {
    case spread
    case moneyline
    case event
}

enum Side: String, Codable, CaseIterable {
    case one
    case two
}

enum BetUserAction {
    case invite
    case uninvite
    case addToSide1
    case addToSide2
    case removeFromSide
    case fulfill
}

struct Bet: Codable {
    var type: BetType
    private(set) var betID: BetID?
    var title: String
    var line: Double?
    var team1: String?
    var team2: String?
    private(set) var invitedUsers = [UID: String]() // UID and userName
    private(set) var side1Users = [UID: String]()
    private(set) var side2Users = [UID: String]()
    private(set) var outstandingUsers = Set<UID>()
    private(set) var allUsers = Set<UID>()
    private(set) var acceptedUsers = Set<UID>()
    var stake: Drinks
    let dateOpened: TimeInterval
    var dueDate: TimeInterval
    private(set) var isFinished = false
    private(set) var winner: Side?
    private(set) var dateFinished: TimeInterval? = nil
    
    mutating func setBetID(withID id: BetID) {
        self.betID = id
    }
    
    mutating func closeBetWith(winningSide: Side) {
        guard !isFinished else { return }
        winner = winningSide
        isFinished = true
        dateFinished = Date().timeIntervalSince1970
        
        // Place losing users into outstanding collection
        switch winningSide {
        case .one:
            side2Users.forEach { outstandingUsers.insert($0.key)}
        case .two:
            side1Users.forEach { outstandingUsers.insert($0.key)}
        }
        
        // Clean invited users off of bet
        for user in invitedUsers {
            let uid = user.key
            allUsers.remove(uid)
            invitedUsers[uid] = nil
        }
    }
    
    mutating func fulfill(forUser uid: UID) {
        outstandingUsers.remove(uid)
    }
    
    mutating func perform(action: BetUserAction, withID uid: UID, userName: String) {
        guard !isFinished else { return } // only allow action if bet still open
        switch action {
        case .invite:
            if !allUsers.contains(uid) {
                invitedUsers[uid] = userName
                allUsers.insert(uid)
            }
        case .uninvite:
            // Check to make sure user has not already accepted
            if !acceptedUsers.contains(uid) && invitedUsers[uid] != nil {
                invitedUsers[uid] = nil
                allUsers.remove(uid)
            }
        case .addToSide1:
            if invitedUsers[uid] != nil && side2Users[uid] == nil {
                invitedUsers[uid] = nil
                side1Users[uid] = userName
                acceptedUsers.insert(uid)
            }
        case .addToSide2:
            if invitedUsers[uid] != nil && side1Users[uid] == nil {
                invitedUsers[uid] = nil
                side2Users[uid] = userName
                acceptedUsers.insert(uid)
            }
        case .removeFromSide:
            side1Users[uid] = nil
            side2Users[uid] = nil
            allUsers.remove(uid)
            acceptedUsers.remove(uid)
        case .fulfill:
            return
        }
        
    }
}
