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
    private var betDocID: BetID
    private(set) var bet: Bet? {
        didSet {
            updateBetCard?()
            checkInvolvementStatus()
        }
    }
    
    private(set) var userInvolvement: BetInvolvementType {
        didSet {
            setUpForInvolvementState?()
        }
    }

    var updateBetCard: (() -> ())?
    var setUpForInvolvementState: (() -> ())?
    var showAlreadyClosedAlert: (() -> ())?
    
    init(firestoreHelper: FirestoreHelper,
         betID: BetID,
         userInvolvement: BetInvolvementType) {
        self.firestoreHelper = firestoreHelper
        self.betDocID = betID
        self.userInvolvement = userInvolvement
    }
    
    func checkInvolvementStatus() {
        // Check user involvement status
        guard let uid = firestoreHelper.currentUser?.uid,
              let bet = bet else { return }
        if bet.invitedUsers[uid] != nil {
            userInvolvement = .invited
        } else if !bet.isFinished && bet.acceptedUsers.contains(uid) {
            userInvolvement = .accepted
        } else if !bet.isFinished {
            userInvolvement = .uninvolved
        } else if bet.outstandingUsers.contains(uid) {
            // User has lost bet and still has to prove that they fulfilled stake
            userInvolvement = .outstanding
        } else if bet.isFinished && !bet.outstandingUsers.contains(uid) {
            // User won bet or fulfilled stake
            userInvolvement = .closed
        }

    }
    
    
    // MARK:- Firestore bet handling methods
    func fetchBet() {
        // Using listener, but need to make sure to fetch right away
        firestoreHelper.readBet(withBetID: betDocID) { [weak self] bet in
            self?.bet = bet
        }
    }
    
    func setBetListener() {
        firestoreHelper.addBetDetailListener(with: betDocID) { [weak self] bet in
            self?.bet = bet
        }
    }
    
    func clearBetListener() {
        firestoreHelper.removeBetDetailListener()
    }
    

    func acceptBet(side: Side) {
        guard let user = firestoreHelper.currentUser,
              userInvolvement == .invited else { return }
        
        // Wait to unwrap bet so we can update the viewModel before copying
        switch side {
        case .one:
            bet?.perform(action: .addToSide1, withID: user.uid, firstName: user.firstName)
        case .two:
            bet?.perform(action: .addToSide2, withID: user.uid, firstName: user.firstName)
        }
        
        
        guard let bet = bet else { return }
        
        // Write the bet then increment user's numBets
        firestoreHelper.updateBet(bet) { [weak self] _ in
            self?.firestoreHelper.updateBetCounter(increasing: true)
        }
    }
    
    func rejectBet() {
        guard let user = firestoreHelper.currentUser,
              userInvolvement == .invited else { return }
        bet?.perform(action: .uninvite, withID: user.uid, firstName: user.firstName)
        
        guard let bet = bet else { return }
        firestoreHelper.updateBet(bet, completion: nil)
    }
    
    func closeBet(withWinner winner: Side) {
        guard userInvolvement == .accepted,
              var bet = bet else { return }
        // Unwrapping a copy of bet first so we don't cause UI changes before we check if the user can actually close the bet.
        bet.closeBetWith(winningSide: winner)
        
        // Method checks if bet was already closed by another user. If so, display alert to user.
        firestoreHelper.closeBet(
            bet,
            betAlreadyClosed: { [weak self] _ in
                self?.showAlreadyClosedAlert?()
            },
            completion: nil
        )        }
    
    func unjoinBet() {
        guard userInvolvement == .accepted,
              let uid = firestoreHelper.currentUser?.uid,
              let firstName = firestoreHelper.currentUser?.firstName else { return }
        bet?.perform(action: .removeFromSide, withID: uid, firstName: firstName)
        
        guard let bet = bet else { return }
        firestoreHelper.updateBet(bet) { [weak self] _ in
            // Decrement user's bet count
            self?.firestoreHelper.updateBetCounter(increasing: false)
        }
    }
    
    func deleteBet() {
        guard let bet = bet else { return }
        firestoreHelper.deleteBet(bet)
    }
    
    func fulfillBet() {
        guard userInvolvement == .outstanding,
              let uid = firestoreHelper.currentUser?.uid else { return }
        bet?.fulfill(forUser: uid)
        
        guard let bet = bet else { return }
        firestoreHelper.updateBet(bet) { [weak self] bet in
            self?.firestoreHelper.updateCountersOnBetFulfillment(with: bet)
        }
    }
    
    // MARK:- Display string parsing
    
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
            return "\(names[0]), \(names[1])"
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
        
        // If user has stake outstanding
        if bet.outstandingUsers.contains(currentUID) {
            return "OUTSTANDING"
        }
        
        // If user is on losing side and has completed stake
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
    
    func getButtonStrings() -> (side1: String?, side2: String?) {
        guard let bet = bet else { return (nil, nil) }
        switch bet.type {
        case .spread:
            return ("TAKE THE OVER", "TAKE THE UNDER")
        case .moneyline:
            return (bet.team1?.uppercased(), bet.team2?.uppercased())
        case .event:
            return ("FOR", "AGAINST")
        }
    }
    
    func getActionSheetStrings() -> (side1: String?, side2: String?) {
        guard let bet = bet else { return (nil, nil) }
        switch bet.type {
        case .spread:
            return ("Over", "Under")
        case .moneyline:
            return (bet.team1, bet.team2)
        case .event:
            return ("For", "Against")
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
