//
//  NewBetViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/1/20.
//

import Foundation
import Firebase

class NewBetViewModel {
    private let firestoreHelper: FirestoreHelper
    
    private(set) var selectedBetType: BetType = .spread {
        didSet {
            createCellVMs() // initiate VMs for new cells when bet type changed
            clearInputStorage() // start fresh when user changes bet type
        }
    }
    private(set) var selectedSide: Side = .one
    
    private(set) var cellViewModels: [BetEntryCellViewModel] = [BetEntryCellViewModel]() {
        didSet {
            reloadTableViewClosure?() // update tableview when cell VMs change
        }
    }
    
    private(set) var isInputComplete = false {
        didSet {
            updateButtonStatus?() // enable/disable button based on user input
        }
    }
    
    var titleInput: String?
    var lineInput: Double?
    var team1Input: String?
    var team2Input: String?
    var dueDateInput: TimeInterval?
    var stakeInput: Drinks?
    
    var reloadTableViewClosure: (() -> ())?
    var updateButtonStatus: (() -> ())?
    var setSendButtonState: (() -> ())?
    
    init(firestoreHelper: FirestoreHelper) {
        self.firestoreHelper = firestoreHelper
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
        case 0...1:
            selectedSide = Side(rawValue: side) ?? .one
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
        default:
            break
        }
        validateInput()
    }
    
    func handle(date: TimeInterval) {
        dueDateInput = date
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
    
    func validateInput() {
        guard let date = dueDateInput,
              let stake = stakeInput else {
            isInputComplete = false
            return
        }
        
        // Do not allow due date in the past
        let isSelectedDateInFuture: Bool = (date - Date.init().timeIntervalSince1970) > 0
        
        // Stake must have positive value in at least one field
        let isStakeValid: Bool = !(stake.beers == 0 && stake.shots == 0)
        switch selectedBetType {
        case .spread:
            if !(titleInput ?? "").isEmpty,
               lineInput != nil,
               isSelectedDateInFuture,
               isStakeValid {
                isInputComplete = true
                return
            }
        case .moneyline:
            if !(team1Input ?? "").isEmpty,
               !(team2Input ?? "").isEmpty,
               isSelectedDateInFuture,
               isStakeValid {
                isInputComplete = true
                return
            }
        case .event:
            if !(titleInput ?? "").isEmpty,
               isSelectedDateInFuture,
               isStakeValid {
                isInputComplete = true
                return
            }
        }
        // If none of the above conditions are satisfied, input is incomplete.
        isInputComplete = false
    }
    
    
    // MARK:- New bet creation
    
    func createNewBet() -> BetID? {
        
        // Check for user auth
        guard let currentUserID = firestoreHelper.currentUser?.uid,
              let currentUserFirstName = firestoreHelper.currentUser?.firstName else {
            fatalError("Unable to find current authorized user.")
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
                fatalError("Invalid data for creation of spread bet.")
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
                fatalError("Invalid data for creation of moneyline bet.")
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
                fatalError("Invalid data for creation of event bet.")
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
        enteredBet.perform(action: .invite, withID: currentUserID, firstName: currentUserFirstName)
        switch selectedSide {
        case .one:
            enteredBet.perform(action: .addToSide1, withID: currentUserID, firstName: currentUserFirstName)
        case .two:
            enteredBet.perform(action: .addToSide2, withID: currentUserID, firstName: currentUserFirstName)
        }
        
        let docID = firestoreHelper.writeNewBet(bet: &enteredBet)
        return docID
    }
    
}
