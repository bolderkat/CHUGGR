//
//  FriendDetailViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/16/20.
//

import Foundation

class FriendDetailViewModel {
    private let firestoreHelper: FirestoreHelper
    private(set) var friend: FullFriend {
        didSet {
            checkFriendStatus()
            updateVCLabels?()
        }
    }
    private(set) var isAlreadyFriends = false {
        didSet {
            // Disable/enable add friend button based on friend status
            doesAddButtonTriggerAdd = !isAlreadyFriends
        }
    }
    // Flag to prevent 2x scrollview loads
    private(set) var isLoading = false
    
    // Flag to prevent fast 2x button press triggering add method twice
    private var doesAddButtonTriggerAdd = true {
        didSet {
            setVCForFriendStatus?()
        }
    }
    // Flag to prevent extra unfollow actions if network is slow to update
    private(set) var isRemoveButtonActive = false
    
    enum SegmentedControlChoice {
        case active
        case pastBets
    }
    var selectedTable: SegmentedControlChoice = .active {
        didSet {
            updateTableView?()
            if selectedTable == .pastBets {
                // Trigger re-fetch when user selects Past Bets to avoid presenting stale data
                initFetchPastBets()
            }
        }
    }
    
    var outstandingBets: [Bet] = [] { // array to be updated by outstanding bet listener
        didSet {
            // Listener changes to array will update cell VMs as well
            processActiveBets(outstandingBets, outstanding: true)
        }
    }
    var outstandingBetCellVMs: [BetCellViewModel] = [] {
        didSet {
            if selectedTable == .active {
                updateTableView?()
            }
        }
    }
    var activeBets: [Bet] = [] {// array to be updated by active bet listener
        didSet {
            // Listener changes to array will update cell VMs as well
            processActiveBets(activeBets, outstanding: false)
        }
    }
    var activeBetCellVMs: [BetCellViewModel] = [] {
        didSet {
            if selectedTable == .active {
                updateTableView?()
            }
        }
    }
    var pastBetCellVMs: [BetCellViewModel] = [] {
        didSet {
            if selectedTable == .pastBets {
                updateTableView?()
            }
        }
    }
    
    var updateVCLabels: (() -> ())?
    var setVCForFriendStatus: (() -> ())?
    var updateTableView: (() -> ())?

    
    init(firestoreHelper: FirestoreHelper, friend: FullFriend) {
        self.firestoreHelper = firestoreHelper
        self.friend = friend
    }
    
    // MARK:- Firestore handlers and bet processing
    func setFriendListener() {
        firestoreHelper.setFriendDetailListener(with: friend.uid) { [weak self] friend in
            self?.friend = friend
        }
    }
    
    func addActiveBetListeners() {
        firestoreHelper.addFriendOutstandingBetListener(for: friend.uid) { [weak self] bets in
            self?.outstandingBets = bets
        }
        
        firestoreHelper.addFriendActiveBetListener(for: friend.uid) { [weak self] bets in
            self?.activeBets = bets
        }
    }
    
    func initFetchPastBets() {
        isLoading = true
        firestoreHelper.initFetchPastBets(for: friend.uid) { [weak self] bets in
            self?.processPastBets(bets, appending: false)
            self?.isLoading = false
        }
    }
    
    func loadAdditionalPastBets() {
        isLoading = true
        firestoreHelper.fetchAdditionalPastBets(for: friend.uid) { [weak self] bets in
            self?.processPastBets(bets, appending: true)
            self?.isLoading = false
        }
    }
    
    func processActiveBets(_ bets: [Bet], outstanding: Bool) {
        var vms = [BetCellViewModel]()
        for bet in bets {
            vms.append(createCellViewModel(for: bet))
        }
        
        if outstanding {
            outstandingBetCellVMs = vms
        } else {
            activeBetCellVMs = vms
        }
    }
    
    func processPastBets(_ bets: [Bet], appending: Bool) {
        var vms = [BetCellViewModel]()
        // Filter out outstanding bets because they are already displayed under active
        let filteredBets = bets.filter { !$0.outstandingUsers.contains(friend.uid) }
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
        BetCellViewModel(bet: bet, firestoreHelper: self.firestoreHelper, friend: friend)
    }
    
    func cleanUpFirestore() {
        firestoreHelper.clearFriendDetail()
    }
    
    // MARK:- Data parsing for UI
    
    func getCellVMsForTable() -> [BetCellViewModel] {
        switch selectedTable {
        case .active:
            return outstandingBetCellVMs + activeBetCellVMs
        case .pastBets:
            return pastBetCellVMs
        }
    }
    
    func getCellVM(at indexPath: IndexPath) -> BetCellViewModel {
        switch selectedTable {
        case .active:
            let array = outstandingBetCellVMs + activeBetCellVMs
            return array[indexPath.row]
        case .pastBets:
            return pastBetCellVMs[indexPath.row]
        }
    }
    
    func getDrinksString(forStat stat: DrinkStatType) -> String? {
        switch stat {
        case .given:
            return "\(friend.drinksGiven.beers) 🍺 \(friend.drinksGiven.shots) 🥃"
        case .received:
            return "\(friend.drinksReceived.beers) 🍺 \(friend.drinksReceived.shots) 🥃"
        case .outstanding:
            return "\(friend.drinksOutstanding.beers) 🍺 \(friend.drinksOutstanding.shots) 🥃"
        }
    }
    
    
    
    // MARK:- Friend actions
    
    func checkFriendStatus() {
        // Check if other user is already friend of current user.
        if firestoreHelper.friends.contains(where: { $0.uid == self.friend.uid }) {
            isAlreadyFriends = true
            isRemoveButtonActive = true
        } else {
            isAlreadyFriends = false
        }
    }
    
    
    func addFriend() {
        // TODO: eventually we want to implement friend requests instead of just doing a unilateral mutual add right away. But for now... gotta push this MVP out!
        
        // Check if this is a valid friend add (i.e., not already friends)
        if !isAlreadyFriends, doesAddButtonTriggerAdd {
            //create friend documents and update client-side friend detail data
            firestoreHelper.addFriend(friend) { [weak self] in
                self?.checkFriendStatus()
            }
        }
        doesAddButtonTriggerAdd = false
    }
    
    func removeFriend() {
        firestoreHelper.removeFriend(withUID: friend.uid) { [weak self] in
            self?.checkFriendStatus()
        }
        isRemoveButtonActive = false
    }
    
}
