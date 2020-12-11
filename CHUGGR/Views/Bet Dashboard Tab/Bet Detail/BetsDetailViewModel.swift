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
    private var betDocID: String?
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
    
    func setBetDocID(withBetID id: String) {
        self.betDocID = id
    }
    
    func fetchBet() {
        firestoreHelper.readBet(withBetID: betDocID) { [weak self] bet in
            self?.bet = bet
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
