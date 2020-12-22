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
    let friend: Friend? // if this holds a value, then this bet cell is being displayed in a friend detail view should be configured to show the status of the bet from the friend's perspective.
        
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
    
    func getTitle() -> String {
        if bet.type == .spread {
            guard let line = bet.line else { return bet.title }
            // Truncate decimal if round number, otherwise keep one decimal.
            let format = line.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f"
            let lineString = String(format: format, line)
            return "\(bet.title): \(lineString)"
        } else {
            return bet.title
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
        // Check if bet is finished/has winner. If not, display "IN PLAY" or "OVERDUE"
        guard let winner = bet.winner else {
            if Date.init().timeIntervalSince1970 > bet.dueDate {
                return("OVERDUE", K.colors.burntUmber)
            } else {
                return ("IN PLAY", K.colors.orange)
            }
        }
        
        // Check if user is involved and which side they are on
        var userSide: Side? = nil
        guard var uid = firestoreHelper.currentUser?.uid else {
            return ("", K.colors.orange)
        }
        
        var nameString = "YOU"
        
        if friend != nil {
            // Perform bet status logic on friend uid instead if this friend cell is being presented in a Friend Detail view
            uid = friend!.uid
            nameString = friend!.firstName.uppercased()
        }
        
        if let _ = bet.side1Users[uid] {
            userSide = .one
        }
        
        
        if let _ = bet.side2Users[uid] {
            userSide = .two
        }
        
        // If user is on winning side
        if let side = userSide,
           side == winner {
            return ("\(nameString) WON", K.colors.forestGreen)
        }
        
        // If user has stake outstanding
        if bet.outstandingUsers.contains(uid) {
            return ("OUTSTANDING", K.colors.burntUmber)
        }
        
        // If user is on losing side
        if let side = userSide,
           side != winner {
            return ("\(nameString) LOST", K.colors.burntUmber)
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
        lhs.bet.betID == rhs.bet.betID &&
        lhs.bet.acceptedUsers == rhs.bet.acceptedUsers // to handle collisions where user is moving into acceptedUsers
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bet.betID)
        hasher.combine(bet.acceptedUsers)
    }
}
