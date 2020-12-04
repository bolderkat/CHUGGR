//
//  BetEntryRowViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/4/20.
//

import Foundation

struct BetEntryRowViewModel: Hashable {
    let type: EntryRowType
    let title: String
    let placeholder: String?
    
    init(type: EntryRowType) {
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
            placeholder = "Enter date bet will occur"
        case .event:
            title = "Event"
            placeholder = "Ex: Half Life 3 announced"
        case .dueDate:
            title = "Due date"
            placeholder = "Optional bet expiration date"
        case .stake:
            title = "Stake"
            placeholder = nil
        }
        self.type = type
    }
}
