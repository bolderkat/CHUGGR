//
//  NewBetViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/1/20.
//

import Foundation

// Define entry row types
enum EntryRowType {
    case stat
    case line
    case team1
    case team2
    case gameday
    case event
    case dueDate
    case stake
}

class NewBetViewModel {
   private(set) var selectedBetType: BetType = .spread {
        didSet {
            createCellVMs()
        }
    }
    private(set) var selectedSide: Side = .one
    
    private(set) var cellViewModels: [BetEntryCellViewModel] = [BetEntryCellViewModel]() {
        didSet {
            reloadTableViewClosure?()
        }
    }
    
    var titleInput: String?
    var lineInput: String?
    var team1Input: String?
    var team2Input: String?
    var dueDateInput: String?
    var beersInput: String?
    var shotsInput: String?
    
    var reloadTableViewClosure: (() -> ())?
    
    
    
    func createCellVMs() {
        let spreadLabels = [
            EntryRowType.stat,
            EntryRowType.line,
            EntryRowType.gameday,
            EntryRowType.stake
        ]
        
        let moneylineLabels = [
            EntryRowType.team1,
            EntryRowType.team2,
            EntryRowType.gameday,
            EntryRowType.stake
        ]
        
        let eventLabels = [
            EntryRowType.event,
            EntryRowType.dueDate,
            EntryRowType.stake
        ]
        
        // Create containers for row types and cell VMs
        var rowTypes = [EntryRowType]()
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
        switch type {
        case 0...2:
            selectedBetType = BetType(rawValue: type) ?? .spread
        default:
            return
        }
    }
    
    func changeSide(_ side: Int) {
        switch side {
        case 0...1:
            selectedSide = Side(rawValue: side) ?? .one
        default:
            return
        }
    }
    
    func createNewBet() {
        // here's where the fun happens...
    }

}
