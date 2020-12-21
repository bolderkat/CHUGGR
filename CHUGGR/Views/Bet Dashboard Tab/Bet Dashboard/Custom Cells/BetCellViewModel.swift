//
//  BetCellViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/13/20.
//

import Foundation

struct BetCellViewModel {
    
    let bet: Bet
    let firestoreHelper: FirestoreHelper
        
    func getSideNames(forSide side: Side) -> String {
        // To get user names on opposing side from current user
        // TODO: need logic to determine opposing side and list other users that are on same side as user
        var names = [String]()
        
        // Populate names array from dictionary in Bet model
        switch side {
        case .one:
            for user in bet.side1Users {
                names.append(user.value)
            }
        case .two:
            for user in bet.side2Users {
                names.append(user.value)
            }
        }
        
        switch names.count {
        case 0:
            return "No one yet"
        case 1:
            return names.first! // can force unwrap as count == 1
        case 2:
            return "(\(names[0]), \(names[1])"
        default:
            return "\(names.count) people"
        }
    }
    
    func getBothSideNames() -> String {
        // To get user names from both sides if current user not involved in bet
        var side1names = [String]()
        var side2names = [String]()
        for user in bet.side1Users {
            side1names.append(user.value)
        }
        for user in bet.side2Users {
            side2names.append(user.value)
        }
        
        let sideCounts: (Int, Int) = (side1names.count, side2names.count)
        
        switch sideCounts {
        case (0, 0):
            return "" // no users
        case (1, 0), (0, 1):
            // Return single name if only one user involved
            return "\(side1names.first ?? "")\(side2names.first ?? "")"
        case (1, 1):
            // Return names if both sides have one person
            // Can force unwrap as we've established both arrays have one element
            return "\(side1names.first!) vs. \(side2names.first!)"
        default:
            // Return concise string if both sides have multiple people
            return "\(side1names.count) people vs. \(side2names.count) people"
            
        }
    }
    
    func getStakeString() -> String {
        return "\(bet.stake.beers) 🍺 \(bet.stake.shots) 🥃"
    }
    
    func getBetStatus() -> String? {
        // Check if bet is finished/has winner. If not, display "IN PLAY"
        guard let winner = bet.winner else { return "IN PLAY" }
        
        // Check if user is involved and which side they are on
        var currentUserSide: Side?
        guard let currentUID = firestoreHelper.currentUser?.uid else { return nil }
        if let _ = bet.side1Users[currentUID] {
            currentUserSide = .one
        }
        
        
        if let _ = bet.side2Users[currentUID] {
            currentUserSide = .two
        }
        
        // If user is on winning side
        if let side = currentUserSide,
           side == winner {
            return "WON"
        }
        
        // If user has stake outstanding
        if bet.outstandingUsers[currentUID] != nil {
            return "OUTSTANDING"
        }
        
        // If user is on losing side
        if let side = currentUserSide,
           side != winner {
            return "LOST"
        }
        
        // If user uninvolved, need to switch on possible outcomes to display
        switch winner {
        case .one:
            switch bet.type {
            case .spread:
                return "OVER"
            case .moneyline:
                return String(bet.team1 ?? "").capitalized
            case .event:
                return "FOR WINS"
            }
        case .two:
            switch bet.type {
            case .spread:
                return "UNDER"
            case .moneyline:
                return String(bet.team2 ?? "").capitalized
            case .event:
                return "AGAINST WINS"
            }
        }
    }
    
}

// MARK:- Hashable
// Add Hashable conformance for TableViewDiffableDataSource
extension BetCellViewModel: Hashable {
    
    // Identify view models based on contained bet IDs
    static func == (lhs: BetCellViewModel, rhs: BetCellViewModel) -> Bool {
        lhs.bet.betID == rhs.bet.betID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bet.betID)
    }
}
