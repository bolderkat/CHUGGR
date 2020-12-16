//
//  BetsViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/12/20.
//

import Foundation

class BetsViewModel {
    private var firestoreHelper: FirestoreHelper
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
    
    private(set) var isLoading = false {
        didSet {
            updateLoadingStatus?()
        }
    }
    
    var updatePendingBetsLabel: (() -> ())?
    var reloadTableViewClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    
    init(firestoreHelper: FirestoreHelper) {
        self.firestoreHelper = firestoreHelper
    }
    
    func initFetchBets() {
        self.isLoading = true
        firestoreHelper.addPendingBetsListener { [weak self] bets in
            self?.pendingBets = bets
        }
        firestoreHelper.addUserInvolvedBetsListener { [weak self] bets in
            self?.processInvolvedBets(bets: bets)
        }
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
        return BetCellViewModel(bet: bet, firestoreHelper: self.firestoreHelper)
    }
    
    func getPendingBetsLabel() -> String {
        var beers = 0
        var shots = 0
        pendingBets.forEach {
            beers += $0.stake.beers
            shots += $0.stake.shots
        }
        
        return "\(beers) 🍺 \(shots) 🥃"
    }
    
}
