//
//  Constants.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/7/20.
//

import Foundation

struct K {
    struct cells {
        static let betCell = "BetCell"
        static let betEntryCell = "BetEntryCell"
        static let betsPendingCell = "BetsPendingCell"
        static let dateCell = "DateEntryCell"
        static let friendCell = "FriendCell"
        static let inviteCell = "InviteCell"
        static let messageCell = "MessageCell"
        static let stakeCell = "StakeEntryCell"
        static let userEntryCell = "UserDetailEntryCell"
    }
    struct colors {
        static let alabaster = "Alabaster"
        static let burntUmber = "Burnt Umber"
        static let lightBlue = "Light Blue"
        static let midBlue = "Mid Blue"
        static let darkBlue = "Dark Blue"
        static let midGray = "Mid Gray"
        static let orange = "CHUGGR Orange"
        static let forestGreen = "Forest Green"
        static let gray1 = "Gray 1"
        static let gray2 = "Gray 2"
        static let gray3 = "Gray 3"
        static let gray4 = "Gray 4"
        static let gray5 = "Gray 5"
        static let gray6 = "Gray 6"
        static let yellow = "Yellow"
    }
    struct Firestore {
        static let acceptedUsers = "acceptedUsers"
        static let allUsers = "allUsers"
        static let betID = "betID"
        static let bets = "bets"
        static let betsLost = "betsLost"
        static let betsWon = "betsWon"
        static let chatRooms = "chatRooms"
        static let dateOpened = "dateOpened"
        static let firstName = "firstName"
        static let friends = "friends"
        static let invitedUsers = "invitedUsers"
        static let isFinished = "isFinished"
        static let numBets = "numBets"
        static let numFriends = "numFriends"
        static let outstandingUsers = "outstandingUsers"
        static let userName = "userName"
        static let uid = "uid"
        static let users = "users"
        static let videos = "videos"
        
        static let beersGiven = "drinksGiven.beers"
        static let shotsGiven = "drinksGiven.shots"
        static let beersOutstanding = "drinksOutstanding.beers"
        static let shotsOutstanding = "drinksOutstanding.shots"
        static let beersReceived = "drinksReceived.beers"
        static let shotsReceived = "drinksReceived.shots"
    }
    
    struct Images {
        static let profPicPlaceholder = "ProfPicPlaceholder"
    }
}
