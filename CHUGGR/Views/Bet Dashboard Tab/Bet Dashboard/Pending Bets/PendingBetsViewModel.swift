//
//  PendingBetsViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/20/20.
//

import Foundation

class PendingBetsViewModel {
    private let firestoreHelper: FirestoreHelping
    private var pendingBets: [Bet] = [] {
        didSet {
            processBets()
        }
    }
    private(set) var betCellVMs: [BetCellViewModel] = [] {
        didSet {
            didUpdateBetCellVMs?()
        }
    }
    
    var didUpdateBetCellVMs: (() -> Void)?
    
    init(firestoreHelper: FirestoreHelping) {
        self.firestoreHelper = firestoreHelper
    }
    
    func setBetListener() {
        firestoreHelper.addUserInvolvedBetsListener { [weak self] _ in
            self?.fetchPendingBets()
        }
    }
    
    func fetchPendingBets() {
        // Get bets where user is in the invited category
        guard let uid = firestoreHelper.currentUser?.uid else { return }
        pendingBets = firestoreHelper.involvedBets.filter { $0.invitedUsers[uid] != nil }
    }
    
    func processBets() {
        var vms = [BetCellViewModel]()
        for bet in pendingBets {
            vms.append(createCellViewModel(for: bet))
        }
        betCellVMs = vms
    }
    
    func createCellViewModel(for bet: Bet) -> BetCellViewModel {
        return BetCellViewModel(bet: bet, firestoreHelper: self.firestoreHelper, friend: nil)
    }
    
    func getCellVM(at indexPath: IndexPath) -> BetCellViewModel {
        return betCellVMs[indexPath.row]
    }
    
}
