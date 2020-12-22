//
//  ProfileViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/11/20.
//

import Foundation
import Firebase

import Foundation

class ProfileViewModel {
    private let firestoreHelper: FirestoreHelper
    private(set) var user: CurrentUser {
        didSet {
            updateVCLabels?()
        }
    }

    // Flag to prevent 2x scrollview loads
    private(set) var isLoading = false

    
    var pastBetCellVMs: [BetCellViewModel] = [] {
        didSet {
            updateTableView?()
        }
    }
    
    var updateVCLabels: (() -> ())?
    var updateTableView: (() -> ())?

    
    init(firestoreHelper: FirestoreHelper, user: CurrentUser) {
        self.firestoreHelper = firestoreHelper
        self.user = user
    }
    
    // MARK:- Firestore handlers and bet processing
    func attachUserToListener() {
        // Called when user changes in FirestoreHelper
        firestoreHelper.currentUserDidChange = { [weak self] user in
            self?.user = user
        }
    }
    
    func initFetchPastBets() {
        // Check if there are no past bet cell VMs, indicating need for first fetch
        isLoading = true
        if pastBetCellVMs.isEmpty {
            firestoreHelper.initFetchPastBets(for: user.uid) { [weak self] bets in
                self?.processPastBets(bets, appending: false)
                self?.isLoading = false
            }
        }
    }
    
    func loadAdditionalPastBets() {
        isLoading = true
        firestoreHelper.fetchAdditionalPastBets(for: user.uid) { [weak self] bets in
            self?.processPastBets(bets, appending: true)
            self?.isLoading = false
        }
    }
    
    func processPastBets(_ bets: [Bet], appending: Bool) {
        var vms = [BetCellViewModel]()
        // Filter out outstanding bets because they are already displayed under active
        let filteredBets = bets.filter { !$0.outstandingUsers.contains(user.uid) }
        for bet in filteredBets {
            vms.append(createCellViewModel(for: bet))
        }
        
        if appending {
            // Append VMs if user has scrolled to bottom of table
            pastBetCellVMs.append(contentsOf: vms)
        } else {
            // Otherwise overwrite the array
            pastBetCellVMs = vms
        }
    }
    
    
    func createCellViewModel(for bet: Bet) -> BetCellViewModel {
        BetCellViewModel(bet: bet, firestoreHelper: self.firestoreHelper, friend: nil)
    }
    
    // MARK:- Data parsing for UI
    
    func getCellVMsForTable() -> [BetCellViewModel] {
        return pastBetCellVMs
    }
    
    func getCellVM(at indexPath: IndexPath) -> BetCellViewModel {
        return pastBetCellVMs[indexPath.row]
    }
    
    func getDrinksString(forStat stat: DrinkStatType) -> String? {
        switch stat {
        case .given:
            return "\(user.drinksGiven.beers) 🍺 \(user.drinksGiven.shots) 🥃"
        case .received:
            return "\(user.drinksReceived.beers) 🍺 \(user.drinksReceived.shots) 🥃"
        case .outstanding:
            return "\(user.drinksOutstanding.beers) 🍺 \(user.drinksOutstanding.shots) 🥃"
        }
    }

    func logOut() {
        firestoreHelper.logOut()
    }
}
