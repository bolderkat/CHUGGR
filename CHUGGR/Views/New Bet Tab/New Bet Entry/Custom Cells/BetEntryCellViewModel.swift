//
//  BetEntryRowViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/4/20.
//

import Foundation

// Define entry row types
enum BetEntryRowType {
    case stat
    case line
    case team1
    case team2
    case gameday
    case event
    case dueDate
    case stake
}

struct BetEntryCellViewModel: Hashable {
    let type: BetEntryRowType
    let title: String
    let placeholder: String?
    
    init(type: BetEntryRowType) {
        switch type {
        case .stat:
            title = "Stat"
            placeholder = "Ex: Lakers vs. Celtics points"
        case .line:
            title = "Line"
            placeholder = "Ex: 192.5"
        case .team1:
            title = "Team 1"
            placeholder = "Ex: Giants"
        case .team2:
            title = "Team 2"
            placeholder = "Ex: Dodgers"
        case .gameday:
            title = "Gameday"
            placeholder = "Date bet will occur"
        case .event:
            title = "Event"
            placeholder = "Ex: Half Life 3 announced"
        case .dueDate:
            title = "Due date"
            placeholder = "Bet expiration date"
        case .stake:
            title = "Stake"
            placeholder = nil
        }
        self.type = type
    }
}
