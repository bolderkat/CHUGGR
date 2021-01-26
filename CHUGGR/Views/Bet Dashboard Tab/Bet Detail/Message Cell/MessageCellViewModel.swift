//
//  MessageCellViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/22/20.
//

import Foundation

struct MessageCellViewModel: Hashable {
    
    
    let message: Message
    let currentUID: UID
    let shouldHideSenderRow: Bool
    var isMessageFromSelf: Bool {
        currentUID == message.uid
    }
    
    init(message: Message,
         shouldHideSenderRow: Bool,
         currentUID: UID) {
        self.message = message
        self.shouldHideSenderRow = shouldHideSenderRow
        self.currentUID = currentUID
    }
    
    func getTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        let date = Date(timeIntervalSince1970: message.timestamp)
        
        // Stylize as "1/25/21 3:30 pm"
        return formatter.string(from: date).lowercased()
    }
    
    
    static func == (lhs: MessageCellViewModel, rhs: MessageCellViewModel) -> Bool {
        lhs.message.uid == rhs.message.uid &&
            lhs.message.timestamp == rhs.message.timestamp &&
            lhs.message.body == rhs.message.body
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(message.uid)
        hasher.combine(message.timestamp)
        hasher.combine(message.body)
    }
}
