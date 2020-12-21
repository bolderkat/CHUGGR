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
        
    func getSideLabels(for side: Side) -> String {
        switch side {
        case .one:
            switch bet.type {
            case .spread:
                return "Over:"
            case .moneyline:
                return "\(String(bet.team1 ?? "").capitalized):"
            case .event:
                return "For:"
            }
        case .two:
            switch bet.type {
            case .spread:
                return "Under:"
            case .moneyline:
                return "\(String(bet.team2 ?? "").capitalized):"
            case .event:
                return "Against:"
            }
        }
    }
    
    func getSideNames(for side: Side) -> String {
        // Provide names of involved users to bet cell
        var names = [String]()
        var dictionary = [UID: String]()
        
        // Populate names array from dictionary in Bet model
        switch side {
        case .one:
            dictionary = bet.side1Users
        case .two:
            dictionary = bet.side2Users
        }
        
        for user in dictionary {
            if user.key == firestoreHelper.currentUser?.uid {
                // Add current user to front of array if found
                names.insert("You", at: 0)
                continue
            }
            names.append(user.value)
        }
        
        switch names.count {
        case 0:
            return ""
        case 1:
            return names[0]
        case 2...5:
            return names.joined(separator: ", ")
        default:
            return "\(names.count) people"
        }
    }
    
    func getStakeString() -> String {
        if bet.stake.shots == 0 {
            return "\(bet.stake.beers) 🍺"
        }
        if bet.stake.beers == 0 {
            return "\(bet.stake.shots) 🥃"
        } else {
            return "\(bet.stake.beers) 🍺 \(bet.stake.shots) 🥃"
        }
    }
    
    func getBetStatusAndColor() -> (label: String, color: String) {
        // Check if bet is finished/has winner. If not, display "IN PLAY"
        guard let winner = bet.winner else { return ("IN PLAY", K.colors.orange) }
        
        // Check if user is involved and which side they are on
        var currentUserSide: Side? = nil
        guard let currentUID = firestoreHelper.currentUser?.uid else {
            return ("", K.colors.orange)
            
        }
        
        if let _ = bet.side1Users[currentUID] {
            currentUserSide = .one
        }
        
        
        if let _ = bet.side2Users[currentUID] {
            currentUserSide = .two
        }
        
        // If user is on winning side
        if let side = currentUserSide,
           side == winner {
            return ("WON", K.colors.forestGreen)
        }
        
        // If user has stake outstanding
        if bet.outstandingUsers.contains(currentUID) {
            return ("OUTSTANDING", K.colors.orange)
        }
        
        // If user is on losing side
        if let side = currentUserSide,
           side != winner {
            return ("LOST", K.colors.burntUmber)
        }
        
        // If user uninvolved, need to switch on possible outcomes to display
        switch winner {
        case .one:
            switch bet.type {
            case .spread:
                return ("OVER", K.colors.midBlue)
            case .moneyline:
                return (String(bet.team1 ?? "").capitalized, K.colors.midBlue)
            case .event:
                return ("FOR WINS", K.colors.midBlue)
            }
        case .two:
            switch bet.type {
            case .spread:
                return ("UNDER", K.colors.midBlue)
            case .moneyline:
                return (String(bet.team2 ?? "").capitalized, K.colors.midBlue)
            case .event:
                return ("AGAINST WINS", K.colors.midBlue)
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
