//
//  NewBetViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/1/20.
//

import Foundation
import Firebase

class NewBetViewModel {
    private let firestoreHelper: FirestoreHelping
    private let invitedFriends: [FriendSnippet]
    
    private(set) var selectedBetType: BetType = .spread {
        didSet {
            createCellVMs()
            clearInputStorage()
        }
    }
    private(set) var selectedSide: Side = .one
    
    private(set) var cellViewModels: [BetEntryCellViewModel] = [BetEntryCellViewModel]() {
        didSet {
            didUpdateCellVMs?() // update tableview when cell VMs change
        }
    }
    
    var titleInput: String?
    var lineInput: Double?
    var team1Input: String?
    var team2Input: String?
    var dueDateInput: TimeInterval?
    var stakeInput: Drinks?
    
    var didUpdateCellVMs: (() -> Void)?
    var userDidSelectFutureDate: ((Bool) -> Void)?
    var didValidateInput: ((Bool) -> Void)? 
    
    init(firestoreHelper: FirestoreHelping, invitedFriends: [FriendSnippet]) {
        self.firestoreHelper = firestoreHelper
        self.invitedFriends = invitedFriends
    }
    
    func getVCTitle() -> String {
        switch invitedFriends.count {
        case 0:
            return "House Bet"
        case 1:
            return "\(invitedFriends[0].firstName) \(invitedFriends[0].lastName)"
        case _ where invitedFriends.count > 1:
            return "Bet with \(invitedFriends.count) people"
        default:
            // Case impossible
            return ""
        }
    }
    
    func createCellVMs() {
        // Define user input rows for each bet type
        let spreadLabels = [
            BetEntryRowType.stat,
            BetEntryRowType.line,
            BetEntryRowType.gameday,
            BetEntryRowType.stake
        ]
        
        let moneylineLabels = [
            BetEntryRowType.team1,
            BetEntryRowType.team2,
            BetEntryRowType.gameday,
            BetEntryRowType.stake
        ]
        
        let eventLabels = [
            BetEntryRowType.event,
            BetEntryRowType.dueDate,
            BetEntryRowType.stake
        ]
        
        // Create containers for row types and cell VMs
        var rowTypes = [BetEntryRowType]()
        var vms = [BetEntryCellViewModel]()
        
        // Provide row types based on selected bet type
        switch selectedBetType {
        case .spread:
            rowTypes = spreadLabels
        case .moneyline:
            rowTypes = moneylineLabels
        case .event:
            rowTypes = eventLabels
        }
        
        // Create cell VM instances based on selected bet type
        for type in rowTypes {
            vms.append(BetEntryCellViewModel(type: type))
        }
        
        // Assign to array of cellViewModels which is provided to table view data source
        // Replaces old cells if present.
        cellViewModels = vms
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> BetEntryCellViewModel {
        cellViewModels[indexPath.row]
    }
    
    func changeBetType(_ type: Int) {
        // Handle user toggling bet type selection control
        switch type {
        case 0:
            selectedBetType = BetType.spread
        case 1:
            selectedBetType = BetType.moneyline
        case 2:
            selectedBetType = BetType.event
        default:
            return
        }
    }
    
    func clearInputStorage() {
        // So user input doesn't stick around after user changes bet type.
        titleInput = nil
        lineInput = nil
        team1Input = nil
        team2Input = nil
        dueDateInput = nil
        stakeInput = nil
        validateInput()
    }
    
    func changeSide(_ side: Int) {
        // Handle user toggling side selection control
        switch side {
        case 0:
            selectedSide = .one
        case 1:
            selectedSide = .two
        default:
            return
        }
    }
    
    // MARK:- Input processing from cells
    
    func handle(text: String, for rowType: BetEntryRowType) {
        // Store textfield input into variables based on row type
        switch rowType {
        case .stat:
            titleInput = text
        case .event:
            titleInput = text
        case .line:
            if text == "" || text == "." {
                lineInput = nil
                break
            }
            
            var lineText = text
            // Clean input if string ends with "."
            if text.last == "." {
                lineText = String(text.dropLast())
            }
            
            // Lines need to be positive numbers
            if let line = Double(lineText), line > 0 {
                lineInput = line
            }
        case .team1:
            team1Input = text
        case .team2:
            team2Input = text
        case .stake, .dueDate, .gameday:
            break
        }
        validateInput()
    }
    
    func handle(date: TimeInterval) {
        dueDateInput = date
        validateDate()
        validateInput()
    }
    
    func handle(beerStake: String?, shotStake: String?) {
        // Blank or noninteger input results in 0
        let beers = Int(beerStake ?? "0") ?? 0
        let shots = Int(shotStake ?? "0") ?? 0
        stakeInput = Drinks(beers: beers, shots: shots)
        validateInput()
    }
    
    
    // MARK:- Input validation to determine if user allowed to submit bet
    func validateDate() {
        guard let date = dueDateInput else {
            userDidSelectFutureDate?(false)
            return
        }
        
        let isSelectedDateInFuture: Bool = (date - Date.init().timeIntervalSince1970) > 0
        if isSelectedDateInFuture {
            userDidSelectFutureDate?(true)
            return
        } else {
            userDidSelectFutureDate?(false)
        }
    }
    
    func validateInput() {
        guard let date = dueDateInput,
              let stake = stakeInput else {
            didValidateInput?(false)
            return
        }
        
        let isSelectedDateInFuture: Bool = (date - Date.init().timeIntervalSince1970) > 0
        
        
        // Stake must have positive value in at least one field
        let isStakeValid: Bool = !(stake.beers == 0 && stake.shots == 0)
        switch selectedBetType {
        case .spread:
            if !(titleInput ?? "").isEmpty,
               lineInput != nil,
               isSelectedDateInFuture,
               isStakeValid {
                didValidateInput?(true)
                return
            }
        case .moneyline:
            if !(team1Input ?? "").isEmpty,
               !(team2Input ?? "").isEmpty,
               isSelectedDateInFuture,
               isStakeValid {
                didValidateInput?(true)
                return
            }
        case .event:
            if !(titleInput ?? "").isEmpty,
               isSelectedDateInFuture,
               isStakeValid {
                didValidateInput?(true)
                return
            }
        }
        // If none of the above conditions are satisfied, input is incomplete.
        didValidateInput?(false)
    }
    
    
    // MARK:- New bet creation
    
    func createNewBet() -> BetID? {
        
        // Check for user auth
        guard let currentUserID = firestoreHelper.currentUser?.uid,
              let currentUserName = firestoreHelper.currentUser?.userName else {
            print("Unable to find current authorized user.")
            return nil
        }
        
        var bet: Bet?
        let currentDate = Date.init().timeIntervalSince1970
        
        // Switch on bet type to decide which values to unwrap
        switch selectedBetType {
        case .spread:
            guard let title = titleInput,
                  let line = lineInput,
                  let dueDate = dueDateInput,
                  let stake = stakeInput else {
                print("Invalid data for creation of spread bet.")
                return nil
            }
            
            bet = Bet(
                type: selectedBetType,
                title: title,
                line: line,
                team1: nil,
                team2: nil,
                stake: stake,
                dateOpened: currentDate,
                dueDate: dueDate
            )
            
        case .moneyline:
            guard let team1 = team1Input,
                  let team2 = team2Input,
                  let dueDate = dueDateInput,
                  let stake = stakeInput else {
                print("Invalid data for creation of moneyline bet.")
                return nil
            }
            
            bet = Bet(
                type: selectedBetType,
                title: "\(team1) vs. \(team2)",
                team1: team1,
                team2: team2,
                stake: stake,
                dateOpened: currentDate,
                dueDate: dueDate
            )
            
        case .event:
            guard let title = titleInput,
                  let dueDate = dueDateInput,
                  let stake = stakeInput else {
                print("Invalid data for creation of event bet.")
                return nil
            }
            
            bet = Bet(type: selectedBetType,
                      title: title,
                      team1: nil,
                      team2: nil,
                      stake: stake,
                      dateOpened: currentDate,
                      dueDate: dueDate
            )
        }
        
        // Make sure we actually have a bet instance after all the above
        guard var enteredBet = bet else { return nil }
        // Add user to bet then assign to selected side.
        enteredBet.perform(action: .invite, withID: currentUserID, userName: currentUserName)
        switch selectedSide {
        case .one:
            enteredBet.perform(action: .addToSide1, withID: currentUserID, userName: currentUserName)
        case .two:
            enteredBet.perform(action: .addToSide2, withID: currentUserID, userName: currentUserName)
        }
        
        // Invite any selected friends
        for friend in invitedFriends {
            enteredBet.perform(action: .invite, withID: friend.uid, userName: friend.userName)
        }
        
        let docID = firestoreHelper.writeNewBet(bet: &enteredBet)
        return docID
    }
    
}
