//
//  BetsViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/12/20.
//

import Foundation

class BetsViewModel {
    private var firestoreHelper: FirestoreHelping
    private(set) var pendingBets = [Bet]() {
        didSet {
            updatePendingBetsLabel?()
        }
    }
    private(set) var userInvolvedBets = [Bet]()
    private(set) var otherBets = [Bet]()
    
    private(set) var userInvolvedBetCellVMs = [BetCellViewModel]() {
        didSet {
            reloadTableViewClosure?()
        }
    }
    private(set) var otherBetCellVMs = [BetCellViewModel]() {
        didSet {
            reloadTableViewClosure?()
        }
    }
    
    private var combinedVMs: [[BetCellViewModel]] {
        // Combined 2D array of VMs for retrieval by tableView IndexPath
        [userInvolvedBetCellVMs, otherBetCellVMs]
    }
    
    private(set) var isLoading = false {
        didSet {
            updateLoadingStatus?()
        }
    }
    
    var updatePendingBetsLabel: (() -> ())?
    var reloadTableViewClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    
    init(firestoreHelper: FirestoreHelping) {
        self.firestoreHelper = firestoreHelper
    }
    
    func initFetchBets() {
        self.isLoading = true
        firestoreHelper.addUserInvolvedBetsListener { [weak self] bets in
            guard let uid = self?.firestoreHelper.currentUser?.uid else { return }
            var pendingBets = [Bet]()
            var involvedBets = [Bet]()
            for bet in bets {
                if bet.invitedUsers[uid] != nil {
                    // Get pending bets user still has to accept/reject
                    pendingBets.append(bet)
                } else if !bet.isFinished || bet.outstandingUsers.contains(uid) {
                    // Show active bets: open bets or bets user has lost and still has to fulfill
                    involvedBets.append(bet)
                }
            }
            self?.pendingBets = pendingBets
            self?.processInvolvedBets(bets: involvedBets)
        }
        initFetchOtherBets()
    }
    
    func initFetchOtherBets() {
        firestoreHelper.initFetchOtherBets { [weak self] bets in
            self?.processOtherBets(bets: bets, appending: false)
        }
    }
    
    
    func loadAdditionalBets() {
        self.isLoading = true
        firestoreHelper.fetchAdditionalBets { [weak self] bets in
            self?.processOtherBets(bets: bets, appending: true)
        }
    }
    
    func processInvolvedBets(bets: [Bet]) {
        var vms = [BetCellViewModel]()
        for bet in bets {
            vms.append(createCellViewModel(for: bet))
        }
        userInvolvedBets = bets
        userInvolvedBetCellVMs = vms
        self.isLoading = false
    }
    
    func processOtherBets(bets: [Bet], appending: Bool) {
        var vms = [BetCellViewModel]()
        for bet in bets {
            vms.append(createCellViewModel(for: bet))
        }
        
        // Append if this is a subsequent fetch after scrolling to bottom of table view.
        if appending {
            otherBets.append(contentsOf: bets)
            otherBetCellVMs.append(contentsOf: vms)
        } else {
            otherBets = bets
            otherBetCellVMs = vms
        }
        self.isLoading = false
    }
    
    func createCellViewModel(for bet: Bet) -> BetCellViewModel {
        return BetCellViewModel(bet: bet, firestoreHelper: self.firestoreHelper, friend: nil)
    }
    
    func getCellVM(at indexPath: IndexPath) -> BetCellViewModel {
        // Index path will vary based on table view config state
        // Which in turn is based on presence of user involved/uninvolved bets
        if userInvolvedBets.isEmpty {
            return otherBetCellVMs[indexPath.row]
        } else if otherBets.isEmpty {
            return userInvolvedBetCellVMs[indexPath.row]
        } else {
            return combinedVMs[indexPath.section][indexPath.row]
        }
    }
    
    func getPendingBetsLabel() -> String {
        switch pendingBets.count {
        case 0:
            return "No bets pending"
        case 1:
            return "1 new bet pending!"
        case _ where pendingBets.count > 1:
            return "\(pendingBets.count) new bets pending!"
        default:
            return ""
        }
    }
    
    func getPendingBetsStake() -> String {
        var beers = 0
        var shots = 0
        pendingBets.forEach {
            beers += $0.stake.beers
            shots += $0.stake.shots
        }
        
        return "\(beers) 🍺 \(shots) 🥃"
    }
    
}
