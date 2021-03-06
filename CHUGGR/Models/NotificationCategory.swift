//
//  NotificationCategory.swift
//  CHUGGR
//
//  Created by Daniel Luo on 1/21/21.
//

import Foundation

// Enum solution for notification categories adapted from https://medium.com/blacklane-engineering/coordinators-essential-tutorial-part-ii-b5ab3eb4a74

struct NotificationCategoryConstants {
    static let newBet = "NEW_BET"
    static let newUninvitedBet = "NEW_UNINVITED_BET"
    static let betWon = "BET_WON"
    static let betLost = "BET_LOST"
    static let newFollower = "NEW_FOLLOWER"
    static let newMessage = "NEW_MESSAGE"
    static let betOutstanding = "BET_OUTSTANDING"
    static let category = "category"
}

enum NotificationCategory {
    case newBet
    case newUninvitedBet
    case betWon
    case betLost
    case newFollower
    case newMessage
    case betOutstanding
    
    static func provideCategory(from dict: [String: Any]?) -> NotificationCategory? {
        let category = dict?[NotificationCategoryConstants.category] as? String
        switch category {
        case NotificationCategoryConstants.newBet:
            return newBet
        case NotificationCategoryConstants.newUninvitedBet:
            return newUninvitedBet
        case NotificationCategoryConstants.betWon:
            return betWon
        case NotificationCategoryConstants.betLost:
            return betLost
        case NotificationCategoryConstants.newFollower:
            return newFollower
        case NotificationCategoryConstants.newMessage:
            return newMessage
        case NotificationCategoryConstants.betOutstanding:
            return betOutstanding
        default:
            return nil
        }
    }
}
