//
//  BetsDetailViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/8/20.
//

import Foundation

class BetDetailViewModel {
    private let firestoreHelper: FirestoreHelping
    private var betDocID: BetID
    private let parentTab: Tab
    private(set) var bet: Bet? {
        didSet {
            didUpdateBet?()
            checkInvolvementStatus()
            setMessageListener()
        }
    }
    
    private(set) var userInvolvement: BetInvolvementType {
        didSet {
            didChangeInvolvementStatus?()
        }
    }
    
    private(set) var messageCellVMs: [MessageCellViewModel] = [] {
        didSet {
            didUpdateMessages?()
        }
    }

    var didUpdateBet: (() -> Void)?
    var didChangeInvolvementStatus: (() -> Void)?
    var betAlreadyClosed: (() -> Void)?
    var didUpdateMessages: (() -> Void)?
    
    init(firestoreHelper: FirestoreHelping,
         betID: BetID,
         parentTab: Tab,
         userInvolvement: BetInvolvementType) {
        self.firestoreHelper = firestoreHelper
        self.betDocID = betID
        self.parentTab = parentTab
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
        firestoreHelper.addBetDetailListener(with: betDocID, in: parentTab) { [weak self] bet in
            self?.bet = bet
        }
    }
    
    func clearBetDetailListeners() {
        firestoreHelper.removeBetDetailListener(for: parentTab)
    }
    

    func acceptBet(side: Side) {
        guard let user = firestoreHelper.currentUser,
              userInvolvement == .invited else { return }
        
        // Wait to unwrap bet so we can update the viewModel before copying
        switch side {
        case .one:
            bet?.perform(action: .addToSide1, withID: user.uid, userName: user.userName)
        case .two:
            bet?.perform(action: .addToSide2, withID: user.uid, userName: user.userName)
        }
        
        guard let bet = bet else { return }
        
        // Write the bet then increment user's numBets
        firestoreHelper.updateBet(bet) { [weak self] _ in
            self?.firestoreHelper.updateBetCounter(increasing: true)
        }
    }
    
    func uninvitedJoinBet(side: Side) {
        // Allow user to join a bet they weren't originally invited to
        guard let user = firestoreHelper.currentUser,
              userInvolvement == .uninvolved else { return }
        
        bet?.perform(action: .invite, withID: user.uid, userName: user.userName)
        
        acceptBet(side: side)
    }
    
    func rejectBet() {
        guard let user = firestoreHelper.currentUser,
              userInvolvement == .invited else { return }
        bet?.perform(action: .uninvite, withID: user.uid, userName: user.userName)
        
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
                self?.betAlreadyClosed?()
            },
            completion: nil
        )
    }
    
    func unjoinBet() {
        guard userInvolvement == .accepted,
              let uid = firestoreHelper.currentUser?.uid,
              let userName = firestoreHelper.currentUser?.userName else { return }
        bet?.perform(action: .removeFromSide, withID: uid, userName: userName)
        
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
    
    
    
    // MARK:- Message Handling
    
    func setMessageListener() {
        switch userInvolvement {
        case .accepted, .outstanding:
            firestoreHelper.addBetMessageListener(with: betDocID, in: parentTab) { [weak self] messages in
                self?.createCellVMs(for: messages)
            }
        case .invited, .uninvolved, .closed:
            return
        }
    }
    
    func sendMessage(with body: String) {
        guard let id = bet?.betID else { return }
        firestoreHelper.sendMessage(for: id, with: body)
    }
    
    func createCellVMs(for messages: [Message]) {
        guard let uid = firestoreHelper.currentUser?.uid else { return }
        var vms = [MessageCellViewModel]()
        
        // Check if previous message is from same sender so we can hide name label
        for i in 0..<messages.count {
            if i == 0 {
                vms.append(MessageCellViewModel(
                    message: messages[i],
                    shouldHideSenderRow: false,
                    currentUID: uid
                ))
            } else {
                // Current message sender matches previous sender and less than 1 hour since last message
                let hourInSeconds = 3600.0
                let timeInterval = messages[i].timestamp - messages[i - 1].timestamp
                if messages[i].uid == messages[i - 1].uid && timeInterval < hourInSeconds {
                    vms.append(MessageCellViewModel(
                        message: messages[i],
                        shouldHideSenderRow: true,
                        currentUID: uid
                    ))
                } else {
                    vms.append(MessageCellViewModel(
                        message: messages[i],
                        shouldHideSenderRow: false,
                        currentUID: uid
                    ))
                }
            }
        }
        
        messageCellVMs = vms
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
            return ""
        case 1:
            return names.first
        case 2:
            return names.joined(separator: ", ")
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
    
    func getBetStatusAndColor() -> (label: String, color: String) {
        guard let bet = bet else {
            return ("", K.colors.orange)
        }
        
        // Check if bet is finished/has winner. If not, display "IN PLAY" or "OVERDUE"
        if let winner = bet.winner {
            return getClosedBetStatusAndColor(bet: bet, winner: winner)
        } else {
            if Date.init().timeIntervalSince1970 > bet.dueDate {
                return("OVERDUE", K.colors.burntUmber)
            } else {
                return ("IN PLAY", K.colors.orange)
            }
        }
    }
    
    func getClosedBetStatusAndColor(bet: Bet, winner: Side) -> (label: String, color: String) {
        guard let uid = firestoreHelper.currentUser?.uid else { return ("", K.colors.orange) }
        
        // If user has stake outstanding
        if bet.outstandingUsers.contains(uid) {
            return ("OUTSTANDING", K.colors.burntUmber)
        }
        
        // Check if user is involved and which side they are on
        var userSide: Side? = nil
        
        
        if let _ = bet.side1Users[uid] {
            userSide = .one
        }
        
        if let _ = bet.side2Users[uid] {
            userSide = .two
        }
        
        // If user is on winning side
        if let side = userSide,
           side == winner {
            return ("YOU WON", K.colors.forestGreen)
        }
        
        // If user is on losing side
        if let side = userSide,
           side != winner {
            return ("YOU LOST", K.colors.burntUmber)
        }
        
        // If user uninvolved, need to switch on possible outcomes to display
        switch winner {
        case .one:
            switch bet.type {
            case .spread:
                return ("OVER", K.colors.midBlue)
            case .moneyline:
                return (String(bet.team1 ?? "").uppercased(), K.colors.midBlue)
            case .event:
                return ("FOR WINS", K.colors.midBlue)
            }
        case .two:
            switch bet.type {
            case .spread:
                return ("UNDER", K.colors.midBlue)
            case .moneyline:
                return (String(bet.team2 ?? "").uppercased(), K.colors.midBlue)
            case .event:
                return ("AGAINST WINS", K.colors.midBlue)
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
            static let leftLabel4 = "Due Date"
            static let leftLabel5 = "At stake"
            static let leftLabel6 = "Status"
        }
        struct Moneyline {
            static let leftLabel1: String? = nil
            static let leftLabel4 = "Due Date"
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
