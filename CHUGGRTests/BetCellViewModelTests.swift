//
//  BetCellViewModelTests.swift
//  CHUGGRTests
//
//  Created by Daniel Luo on 1/11/21.
//

import XCTest
@testable import CHUGGR

class BetCellViewModelTests: XCTestCase {

    private var sut: BetCellViewModel!
    private var mock: MockFirestoreHelper!
    let uid = "uid"
    let firstName = "firstName"
    var userDict: [UID: String] {
        [uid: firstName]
    }
    let friend = FullFriend(uid: "friendUID", firstName: "friendFName", lastName: "friendLName", userName: "friendUserName", bio: "friendBio", profilePic: "friendProfPic", numBets: 0, numFriends: 0, betsWon: 0, betsLost: 0, drinksGiven: Drinks(beers: 0, shots: 0), drinksReceived: Drinks(beers: 0, shots: 0), drinksOutstanding: Drinks(beers: 0, shots: 0))
    
    let spreadBet = Bet(
        type: .spread,
        betID: "betID",
        title: "title",
        team1: nil,
        team2: nil,
        stake: Drinks(beers: 1, shots: 1),
        dateOpened: Date.init().timeIntervalSince1970,
        dueDate: Date.init().timeIntervalSince1970 + 10000
    )
    
    let moneylineBet = Bet(
        type: .moneyline,
        betID: "betID",
        title: "Team1 vs. Team2",
        team1: "team1",
        team2: "team2",
        stake: Drinks(beers: 1, shots: 1),
        dateOpened: Date.init().timeIntervalSince1970,
        dueDate: Date.init().timeIntervalSince1970 + 10000
    )
    
    let eventBet = Bet(
        type: .event,
        betID: "betID",
        title: "eventTitle",
        team1: nil,
        team2: nil,
        stake: Drinks(beers: 1, shots: 1),
        dateOpened: Date.init().timeIntervalSince1970,
        dueDate: Date.init().timeIntervalSince1970 + 10000
    )

    
    override func setUp() {
        super.setUp()
        mock = MockFirestoreHelper()
        // SUT bet property is immutable so must initialize SUT with needed bet in each individual test
    }
    
    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }
    
    func test_getSideLabelsForSpread() {
        sut = BetCellViewModel(bet: spreadBet, firestoreHelper: mock, friend: nil)
        XCTAssertEqual(sut.getSideLabels(for: .one), "Over:")
        XCTAssertEqual(sut.getSideLabels(for: .two), "Under:")
    }
    
    func test_getSideLabelsForMoneyline() {
        sut = BetCellViewModel(bet: moneylineBet, firestoreHelper: mock, friend: nil)
        XCTAssertEqual(sut.getSideLabels(for: .one), "Team1:")
        XCTAssertEqual(sut.getSideLabels(for: .two), "Team2:")
    }
    
    func test_getSideLabelsForEvent() {
        sut = BetCellViewModel(bet: eventBet, firestoreHelper: mock, friend: nil)
        XCTAssertEqual(sut.getSideLabels(for: .one), "For:")
        XCTAssertEqual(sut.getSideLabels(for: .two), "Against:")
    }
    
    func test_getSpreadTitle() {
        let userInputValues = [0, 0.5000, 012.583929, 00002.000001, 0.1205738298, 120, 2.0]
        let expectedStrings = ["0", "0.5", "12.6", "2.0", "0.1", "120", "2"]
        for i in 0..<userInputValues.count {
            let bet = Bet(
                type: .spread,
                betID: "betID",
                title: "title",
                line: userInputValues[i],
                team1: nil,
                team2: nil,
                stake: Drinks(beers: 1, shots: 1),
                dateOpened: Date.init().timeIntervalSince1970,
                dueDate: Date.init().timeIntervalSince1970 + 10000
            )
            sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
            XCTAssertEqual(sut.getTitle(), "\(bet.title): \(expectedStrings[i])")
        }
    }
    
    func test_getSpreadTitleWithNilLine() {
        sut = BetCellViewModel(bet: spreadBet, firestoreHelper: mock, friend: nil)
        XCTAssertEqual(sut.getTitle(), "title")
    }
    
    func test_getMoneylineTitle() {
        sut = BetCellViewModel(bet: moneylineBet, firestoreHelper: mock, friend: nil)
        XCTAssertEqual(sut.getTitle(), "Team1 vs. Team2")
    }
    
    func test_getEventTitle() {
        sut = BetCellViewModel(bet: eventBet, firestoreHelper: mock, friend: nil)
        XCTAssertEqual(sut.getTitle(), "eventTitle")
    }
    
    func test_getSideNamesWithNoUsers() {
        sut = BetCellViewModel(bet: spreadBet, firestoreHelper: mock, friend: nil)
        XCTAssertEqual(sut.getSideNames(for: .one), "")
        XCTAssertEqual(sut.getSideNames(for: .two), "")
    }
    
    func test_getSideNamesFromBetWithSomeUsers() {
        let bet = Bet(
            type: .event,
            betID: "betID",
            title: "title",
            line: nil,
            team1: nil,
            team2: nil,
            invitedUsers: [:],
            side1Users: [
                "1": "a",
                "2": "b",
            ],
            side2Users: ["3": "c"],
            outstandingUsers: Set<UID>(),
            allUsers: Set<UID>(),
            acceptedUsers: Set<UID>(),
            stake: Drinks(beers: 0, shots: 0),
            dateOpened: 0,
            dueDate: 1,
            isFinished: false,
            winner: nil,
            dateFinished: nil
        )
        sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
        
        let possibleCombos = ["a, b", "b, a"]
        
        XCTAssertTrue(possibleCombos.contains(sut.getSideNames(for: .one)))
        XCTAssertEqual(sut.getSideNames(for: .two), "c")
    }
    
    func test_getSideNamesFromBetWithManyUsers() {
        let bet = Bet(
            type: .event,
            betID: "betID",
            title: "title",
            line: nil,
            team1: nil,
            team2: nil,
            invitedUsers: [:],
            side1Users: [
                "1": "a",
                "2": "b",
                "5": "e",
                "0": "?"
            ],
            side2Users: [
                "3": "c",
                "6": "f",
                "7": "g",
                "8": "h",
                "9": "j",
                "10": "k",
                "11": "l"
            ],
            outstandingUsers: Set<UID>(),
            allUsers: Set<UID>(),
            acceptedUsers: Set<UID>(),
            stake: Drinks(beers: 0, shots: 0),
            dateOpened: 0,
            dueDate: 1,
            isFinished: false,
            winner: nil,
            dateFinished: nil
        )
        
        sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
        let side1String = sut.getSideNames(for: .one)
        let side1Count = bet.side1Users.count
        let side2String = sut.getSideNames(for: .two)
        let side2Count = bet.side2Users.count
        
        // Can't test side1String equality directly as dicts are unordered
        let side1ExpectedCharacters = (side1Count - 1) * 3 + 1 // name, comma, space
        let numSide1Separators = side1String.filter { $0 == "," }.count
        XCTAssertEqual(numSide1Separators, side1Count - 1)
        XCTAssertEqual(side1String.count, side1ExpectedCharacters)
        
        XCTAssertEqual(side2String, "\(side2Count) people")
    }
    
    func test_getSideNameWithCurrentUserOnSideOne() {
        let bet = Bet(
            type: .event,
            betID: "betID",
            title: "title",
            line: nil,
            team1: nil,
            team2: nil,
            invitedUsers: [:],
            side1Users: [
                "1": "a",
                "2": "b",
                "5": "e",
                "0": "?",
                "uid": "firstName"
            ],
            side2Users: [:],
            outstandingUsers: Set<UID>(),
            allUsers: Set<UID>(),
            acceptedUsers: Set<UID>(),
            stake: Drinks(beers: 0, shots: 0),
            dateOpened: 0,
            dueDate: 1,
            isFinished: false,
            winner: nil,
            dateFinished: nil
        )
        sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
        let side1String = sut.getSideNames(for: .one)
        XCTAssertTrue(side1String.contains("You"))
    }
    
    func test_getSideNameWithUserOnSideTwo() {
        let bet = Bet(
            type: .event,
            betID: "betID",
            title: "title",
            line: nil,
            team1: nil,
            team2: nil,
            invitedUsers: [:],
            side1Users: [:],
            side2Users: ["uid": "firstName"],
            outstandingUsers: Set<UID>(),
            allUsers: Set<UID>(),
            acceptedUsers: Set<UID>(),
            stake: Drinks(beers: 0, shots: 0),
            dateOpened: 0,
            dueDate: 1,
            isFinished: false,
            winner: nil,
            dateFinished: nil
        )
        sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
        XCTAssertEqual(sut.getSideNames(for: .two), "You")
    }
    
    func test_getDoubleStakeString() {
        let bet = Bet(
            type: .spread,
            betID: "betID",
            title: "title",
            team1: nil,
            team2: nil,
            stake: Drinks(beers: 2, shots: 2),
            dateOpened: Date.init().timeIntervalSince1970,
            dueDate: Date.init().timeIntervalSince1970 + 10000
        )
        sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
        XCTAssertEqual(sut.getStakeString(), "2 🍺 2 🥃")
    }
    
    func test_getBeerStakeString() {
        let bet = Bet(
            type: .spread,
            betID: "betID",
            title: "title",
            team1: nil,
            team2: nil,
            stake: Drinks(beers: 289089089, shots: 0),
            dateOpened: Date.init().timeIntervalSince1970,
            dueDate: Date.init().timeIntervalSince1970 + 10000
        )
        sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
        XCTAssertEqual(sut.getStakeString(), "289089089 🍺")
    }
    
    func test_getShotStakeString() {
        let bet = Bet(
            type: .spread,
            betID: "betID",
            title: "title",
            team1: nil,
            team2: nil,
            stake: Drinks(beers: 0, shots: -242),
            dateOpened: Date.init().timeIntervalSince1970,
            dueDate: Date.init().timeIntervalSince1970 + 10000
        )
        sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
        XCTAssertEqual(sut.getStakeString(), "-242 🥃")
    }
    
    func test_getDoubleZeroStakeString() {
        let bet = Bet(
            type: .spread,
            betID: "betID",
            title: "title",
            team1: nil,
            team2: nil,
            stake: Drinks(beers: 0, shots: 0),
            dateOpened: Date.init().timeIntervalSince1970,
            dueDate: Date.init().timeIntervalSince1970 + 10000
        )
        sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
        XCTAssertEqual(sut.getStakeString(), "0 🍺 0 🥃")
    }
    
    func test_getClosedBetStatusWithNilUser() {
        var bet = spreadBet
        bet.closeBetWith(winningSide: .one)
        mock.currentUser = nil
        sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
        XCTAssertEqual(sut.getBetStatusAndColor().label, "")
        XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.orange)
    }
    
    func test_getInPlayBetStatus() {
        sut = BetCellViewModel(bet: spreadBet, firestoreHelper: mock, friend: nil)
        XCTAssertEqual(sut.getBetStatusAndColor().label, "IN PLAY")
        XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.orange)
    }
    
    func test_getOverdueBetStatus() {
        var bet = spreadBet
        bet.dueDate = 0
        sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
        XCTAssertEqual(sut.getBetStatusAndColor().label, "OVERDUE")
        XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.burntUmber)
    }
    
    func test_getOutstandingBetStatus() {
        for side in Side.allCases {
            switch side {
            case .one:
                var bet = eventBet
                bet.perform(action: .invite, withID: uid, firstName: firstName)
                bet.perform(action: .addToSide1, withID: uid, firstName: firstName)
                bet.closeBetWith(winningSide: .two)
                sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
                XCTAssertEqual(sut.getBetStatusAndColor().label, "OUTSTANDING")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.burntUmber)
            case .two:
                var bet = eventBet
                bet.perform(action: .invite, withID: uid, firstName: firstName)
                bet.perform(action: .addToSide2, withID: uid, firstName: firstName)
                bet.closeBetWith(winningSide: .one)
                sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
                XCTAssertEqual(sut.getBetStatusAndColor().label, "OUTSTANDING")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.burntUmber)
            }
        }
    }
    
    func test_getUserWonBetStatus() {
        for side in Side.allCases {
            switch side {
            case .one:
                var bet = spreadBet
                bet.perform(action: .invite, withID: uid, firstName: firstName)
                bet.perform(action: .addToSide1, withID: uid, firstName: firstName)
                bet.closeBetWith(winningSide: .one)
                sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
                XCTAssertEqual(sut.getBetStatusAndColor().label, "YOU WON")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.forestGreen)
            case .two:
                var bet = spreadBet
                bet.perform(action: .invite, withID: uid, firstName: firstName)
                bet.perform(action: .addToSide2, withID: uid, firstName: firstName)
                bet.closeBetWith(winningSide: .two)
                sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
                XCTAssertEqual(sut.getBetStatusAndColor().label, "YOU WON")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.forestGreen)
            }
        }
    }
    
    func test_getFriendWonBetStatus() {
        for side in Side.allCases {
            switch side {
            case .one:
                var bet = spreadBet
                bet.perform(action: .invite, withID: friend.uid, firstName: friend.firstName)
                bet.perform(action: .addToSide1, withID: friend.uid, firstName: friend.uid)
                bet.closeBetWith(winningSide: .one)
                sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: friend)
                XCTAssertEqual(sut.getBetStatusAndColor().label, "\(friend.firstName.uppercased()) WON")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.forestGreen)
            case .two:
                var bet = spreadBet
                bet.perform(action: .invite, withID: friend.uid, firstName: friend.uid)
                bet.perform(action: .addToSide2, withID: friend.uid, firstName: friend.uid)
                bet.closeBetWith(winningSide: .two)
                sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: friend)
                XCTAssertEqual(sut.getBetStatusAndColor().label, "\(friend.firstName.uppercased()) WON")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.forestGreen)
            }
        }
    }
    
    func test_getUserLostBetStatus() {
        for side in Side.allCases {
            switch side {
            case .one:
                var bet = spreadBet
                bet.perform(action: .invite, withID: uid, firstName: firstName)
                bet.perform(action: .addToSide1, withID: uid, firstName: firstName)
                bet.closeBetWith(winningSide: .two)
                bet.fulfill(forUser: uid)
                sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
                XCTAssertEqual(sut.getBetStatusAndColor().label, "YOU LOST")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.burntUmber)
            case .two:
                var bet = spreadBet
                bet.perform(action: .invite, withID: uid, firstName: firstName)
                bet.perform(action: .addToSide2, withID: uid, firstName: firstName)
                bet.closeBetWith(winningSide: .one)
                bet.fulfill(forUser: uid)
                sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
                XCTAssertEqual(sut.getBetStatusAndColor().label, "YOU LOST")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.burntUmber)
            }
        }
    }
    
    func test_getFriendLostBetStatus() {
        for side in Side.allCases {
            switch side {
            case .one:
                var bet = spreadBet
                bet.perform(action: .invite, withID: friend.uid, firstName: friend.firstName)
                bet.perform(action: .addToSide1, withID: friend.uid, firstName: friend.uid)
                bet.closeBetWith(winningSide: .two)
                bet.fulfill(forUser: friend.uid)
                sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: friend)
                XCTAssertEqual(sut.getBetStatusAndColor().label, "\(friend.firstName.uppercased()) LOST")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.burntUmber)
            case .two:
                var bet = spreadBet
                bet.perform(action: .invite, withID: friend.uid, firstName: friend.uid)
                bet.perform(action: .addToSide2, withID: friend.uid, firstName: friend.uid)
                bet.closeBetWith(winningSide: .one)
                bet.fulfill(forUser: friend.uid)
                sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: friend)
                XCTAssertEqual(sut.getBetStatusAndColor().label, "\(friend.firstName.uppercased()) LOST")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.burntUmber)
            }
        }
    }
    
    func test_getUninvolvedClosedSpreadBetStatus() {
        for side in Side.allCases {
            var bet = spreadBet
            bet.closeBetWith(winningSide: side)
            sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
            switch side {
            case .one:
                XCTAssertEqual(sut.getBetStatusAndColor().label, "OVER")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.midBlue)
            case .two:
                XCTAssertEqual(sut.getBetStatusAndColor().label, "UNDER")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.midBlue)
            }
        }
    }
    
    func test_getUninvolvedClosedMoneylineBetStatus() {
        for side in Side.allCases {
            var bet = moneylineBet
            bet.type = .moneyline
            bet.closeBetWith(winningSide: side)
            sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
            switch side {
            case .one:
                XCTAssertEqual(sut.getBetStatusAndColor().label, "TEAM1")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.midBlue)
            case .two:
                XCTAssertEqual(sut.getBetStatusAndColor().label, "TEAM2")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.midBlue)
            }
        }
    }
    
    func test_getUninvolvedClosedMoneylineWithNilTeamNamesBetStatus() {
        for side in Side.allCases {
            var bet = moneylineBet
            bet.type = .moneyline
            bet.team1 = nil
            bet.team2 = nil
            bet.closeBetWith(winningSide: side)
            sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
            switch side {
            case .one:
                XCTAssertEqual(sut.getBetStatusAndColor().label, "")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.midBlue)
            case .two:
                XCTAssertEqual(sut.getBetStatusAndColor().label, "")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.midBlue)
            }
        }
    }


    func test_getUninvolvedClosedEventBetStatus() {
        for side in Side.allCases {
            var bet = eventBet
            bet.closeBetWith(winningSide: side)
            sut = BetCellViewModel(bet: bet, firestoreHelper: mock, friend: nil)
            switch side {
            case .one:
                XCTAssertEqual(sut.getBetStatusAndColor().label, "FOR WINS")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.midBlue)
            case .two:
                XCTAssertEqual(sut.getBetStatusAndColor().label, "AGAINST WINS")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.midBlue)
            }
        }
    }
    
    func test_equalityOperator() {
        let bet1 = Bet(
            type: .event,
            betID: "betID",
            title: "title",
            line: nil,
            team1: nil,
            team2: nil,
            invitedUsers: [:],
            side1Users: [:],
            side2Users: ["uid": "firstName"],
            outstandingUsers: Set<UID>(),
            allUsers: Set<UID>(),
            acceptedUsers: Set<UID>(["uid"]),
            stake: Drinks(beers: 0, shots: 0),
            dateOpened: 0,
            dueDate: 1,
            isFinished: false,
            winner: nil,
            dateFinished: nil
        )
        let bet2 = Bet(
            type: .event,
            betID: "betID",
            title: "title",
            line: nil,
            team1: nil,
            team2: nil,
            invitedUsers: [:],
            side1Users: [:],
            side2Users: ["uid": "firstName"],
            outstandingUsers: Set<UID>(),
            allUsers: Set<UID>(),
            acceptedUsers: Set<UID>(["uid"]),
            stake: Drinks(beers: 0, shots: 0),
            dateOpened: 0,
            dueDate: 1,
            isFinished: false,
            winner: nil,
            dateFinished: nil
        )
        
        let vm1 = BetCellViewModel(bet: bet1, firestoreHelper: mock, friend: nil)
        let vm2 = BetCellViewModel(bet: bet2, firestoreHelper: mock, friend: nil)
        
        XCTAssertTrue(vm1 == vm2)
    }

}
