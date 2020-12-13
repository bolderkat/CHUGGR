//
//  BetsDetailViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/8/20.
//

import Foundation
import Firebase

class BetsDetailViewModel {
    private let firestoreHelper: FirestoreHelper
    private var betDocID: BetID?
    private(set) var bet: Bet? {
        didSet {
            DispatchQueue.main.async {
                self.updateBetCard?()
            }
        }
    }
    // First names for users involved in bets, read from db
    private(set) var side1 = [String]()
    private(set) var side2 = [String]()
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
            return "\(names.count) users"
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
        return bet.isFinished ? "FINISHED" : "IN PLAY"
    }
}

extension BetsDetailViewModel {
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
