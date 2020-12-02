//
//  NewBetViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/1/20.
//

import Foundation

struct EntryRow: Hashable {
    let title: String
    let placeholder: String?
}

class NewBetViewModel {
    
    
    private let spreadLabels = [
        EntryRow(title: "Stat", placeholder: "Ex: Lakers vs. Celtics points"),
        EntryRow(title: "Line", placeholder: "Ex: 192.5"),
        EntryRow(title: "Gameday", placeholder: "Enter date bet will occur"),
        EntryRow(title: "Stake", placeholder: nil)
    ]
    
    private let moneylineLabels = [
        EntryRow(title: "Team 1", placeholder: "Ex: Dodgers"),
        EntryRow(title: "Team 2", placeholder: "Ex: Giants"),
        EntryRow(title: "Gameday", placeholder: "Enter date bet will occur"),
        EntryRow(title: "Stake", placeholder: nil)
    ]
    
    private let eventLabels = [
        EntryRow(title: "Event", placeholder: "Ex: Half Life 3 announced"),
        EntryRow(title: "Due date", placeholder: "Optional bet expiration date"),
        EntryRow(title: "Stake", placeholder: nil)
    ]
    
    func getRowLabels(for betType: BetType) -> [EntryRow] {
        switch betType {
        case .spread:
            return spreadLabels
        case .moneyline:
            return moneylineLabels
        case .event:
            return eventLabels
        }
    }

}
