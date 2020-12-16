//
//  BetsDetailViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/8/20.
//

import Foundation
import Firebase

class BetDetailViewModel {
    private let firestoreHelper: FirestoreHelper
    private var betDocID: BetID?
    private(set) var bet: Bet? {
        didSet {
            DispatchQueue.main.async {
                self.updateBetCard?()
            }
        }
    }

    var updateBetCard: (() -> ())?
    
    init(firestoreHelper: FirestoreHelper) {
        self.firestoreHelper = firestoreHelper
    }
    
    func setBetDocID(withBetID id: BetID) {
        self.betDocID = id
    }
    
    func fetchBet() {
        // Need to put on background queue here?
        firestoreHelper.readBet(withBetID: betDocID) { [weak self] (bet) in
            self?.bet = bet
        }
    }
    
    func getBetLine() -> String? {
        guard let line = bet?.line else { return nil }
        // Truncate decimal if round number, otherwise keep one decimal.
        let format = line.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f"
        return String(format: format, line)
    }
    
    func getSideNames(forSide side: Side) -> String? {
        guard let bet = bet else { return nil }
        var names = [String]()
        
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
            return names.first
        case 2:
            return "(\(names[0]), \(names[1])"
        default:
            return "\(names.count) people"
        }
    }
    
    
    func getDateString() -> String? {
        guard let bet = bet else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let dueDate = Date(timeIntervalSince1970: bet.dueDate)
        return dateFormatter.string(from: dueDate)
    }
    
    func getStakeString() -> String? {
        guard let bet = bet else { return nil }
        return "\(bet.stake.beers) 🍺 \(bet.stake.shots) 🥃"
    }
    
    func getBetStatus() -> String? {
        guard let bet = bet else { return nil }
        
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

extension BetDetailViewModel {
    // MARK:- Constants for bet card labels
    struct Labels {
        struct Spread {
            static let leftLabel1 = "Line"
            static let leftLabel2 = "Over"
            static let leftLabel3 = "Under"
            static let leftLabel4 = "Gameday"
            static let leftLabel5 = "At stake"
            static let leftLabel6 = "Status"
        }
        struct Moneyline {
            static let leftLabel1: String? = nil
            static let leftLabel4 = "Gameday"
            static let leftLabel5 = "At stake"
            static let leftLabel6 = "Status"
        }
        struct Event {
            static let leftLabel1: String? = nil
            static let leftLabel2 = "For"
            static let leftLabel3 = "Against"
            static let leftLabel4 = "Due Date"
            static let leftLabel5 = "At stake"
            static let leftLabel6 = "Status"
        }
    }
}
