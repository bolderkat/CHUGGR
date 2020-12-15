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
            endRefreshControl?()
        }
    }
    private(set) var otherBetCellVMs = [BetCellViewModel]() {
        didSet {
            reloadTableViewClosure?()
            endRefreshControl?()
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
    var endRefreshControl: (() -> ())?
    
    init(firestoreHelper: FirestoreHelper) {
        self.firestoreHelper = firestoreHelper
    }
    
    func initFetchBets() {
        self.isLoading = true
        firestoreHelper.addPendingBetsListener { [weak self] bets in
            self?.pendingBets = bets
        }
        refreshBets()
    }
    
    func refreshBets() {
        firestoreHelper.addUserInvolvedBetsListener { [weak self] bets in
            self?.processInvolvedBets(bets: bets)
        }
        
        firestoreHelper.fetchOtherBets { [weak self] bets in
            self?.processOtherBets(bets: bets)
        }
    }
    
    func processInvolvedBets(bets: [Bet]) {
        var vms = [BetCellViewModel]()
        for bet in bets {
            vms.append(createCellViewModel(for: bet))
        }
        userInvolvedBets = bets
        userInvolvedBetCellVMs = vms
    }
    
    func processOtherBets(bets: [Bet]) {
        var vms = [BetCellViewModel]()
        for bet in bets {
            vms.append(createCellViewModel(for: bet))
        }
        otherBets = bets
        otherBetCellVMs = vms
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
