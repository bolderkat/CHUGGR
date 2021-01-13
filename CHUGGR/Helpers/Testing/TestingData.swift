//
//  TestingData.swift
//  CHUGGR
//
//  Created by Daniel Luo on 1/12/21.
//

import Foundation

struct TestingData {
    static let friends: [FullFriend] = [
        FullFriend(
            uid: "friend1",
            firstName: "A",
            lastName: "1",
            userName: "ZZ",
            bio: "A1 bio",
            profilePic: "A1 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        ),
        FullFriend(
            uid: "friend2",
            firstName: "B",
            lastName: "2",
            userName: "YY",
            bio: "B2 bio",
            profilePic: "B2 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        ),
        FullFriend(
            uid: "friend3",
            firstName: "C",
            lastName: "3",
            userName: "XX",
            bio: "C3 bio",
            profilePic: "C3 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        ),
        FullFriend(
            uid: "friend4",
            firstName: "D",
            lastName: "4",
            userName: "WW",
            bio: "D4 bio",
            profilePic: "D4 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        ),
        FullFriend(
            uid: "friend5",
            firstName: "E",
            lastName: "5",
            userName: "VV",
            bio: "E5 bio",
            profilePic: "E5 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        ),
        FullFriend(
            uid: "friend6",
            firstName: "F",
            lastName: "6",
            userName: "UU",
            bio: "F6 bio",
            profilePic: "F6 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        ),
        FullFriend(
            uid: "friend7",
            firstName: "G",
            lastName: "7",
            userName: "TT",
            bio: "G7 bio",
            profilePic: "G7 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        ),
        FullFriend(
            uid: "friend8",
            firstName: "H",
            lastName: "8",
            userName: "SS",
            bio: "H8 bio",
            profilePic: "H8 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        )
    ]
    
    // USERS:
    // Alex Smith - alexSmith94
    // Alex Copperton - ac2020
    // Patrick Mahomes - MrPMII
    // Patrick Star - MrWumbo
    // Wardell Stephen Curry - splashbro30
    // Damion Curry - dLee
    // Russell Wilson - dangerussWilson
    // Russell Westbrook - recoveringbruin44
    // 2 friends already followed by user
    static let users: [FullFriend] = [
        FullFriend(
            uid: "user1",
            firstName: "Alex",
            lastName: "Smith",
            userName: "alexSmith94",
            bio: "A1 bio",
            profilePic: "A1 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        ),
        FullFriend(
            uid: "user2",
            firstName: "Alex",
            lastName: "Copperton",
            userName: "ac2020",
            bio: "B2 bio",
            profilePic: "B2 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        ),
        FullFriend(
            uid: "user3",
            firstName: "Patrick",
            lastName: "Mahomes",
            userName: "MrPMII",
            bio: "C3 bio",
            profilePic: "C3 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        ),
        FullFriend(
            uid: "user4",
            firstName: "Patrick",
            lastName: "Star",
            userName: "MrWumbo",
            bio: "No this is Patrick",
            profilePic: "D4 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        ),
        FullFriend(
            uid: "user5",
            firstName: "Wardell Stephen",
            lastName: "Curry",
            userName: "splashbro30",
            bio: "I don't miss.",
            profilePic: "E5 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        ),
        FullFriend(
            uid: "user6",
            firstName: "Damion",
            lastName: "Curry",
            userName: "dLee",
            bio: "No I didn't actually change my legal last name",
            profilePic: "F6 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        ),
        FullFriend(
            uid: "user7",
            firstName: "Russell",
            lastName: "Wilson",
            userName: "dangerussWilson",
            bio: "Let me cook",
            profilePic: "G7 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        ),
        FullFriend(
            uid: "user8",
            firstName: "Russell",
            lastName: "Westbrook",
            userName: "recoveringbruin44",
            bio: "My only regret is going to UCLA.",
            profilePic: "H8 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        ),
        FullFriend(
            uid: "friend1",
            firstName: "FriendA",
            lastName: "1",
            userName: "ZZ",
            bio: "A1 bio",
            profilePic: "A1 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        ),
        FullFriend(
            uid: "friend2",
            firstName: "FriendB",
            lastName: "2",
            userName: "YY",
            bio: "B2 bio",
            profilePic: "B2 prof pic",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0)
        )
    ]
}
