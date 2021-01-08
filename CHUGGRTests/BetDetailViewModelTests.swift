//
//  BetDetailViewModelTests.swift
//  CHUGGRTests
//
//  Created by Daniel Luo on 1/6/21.
//

import XCTest
@testable import CHUGGR

class BetDetailViewModelTests: XCTestCase {

    private var sut: BetDetailViewModel!
    private var mock: MockFirestoreHelper!
    var sampleBet: Bet!
    let uid = "uid"
    let firstName = "firstName"
    var userDict: [UID: String] {
        [uid: firstName]
    }
    
    override func setUp() {
        super.setUp()
        mock = MockFirestoreHelper()
        sut = BetDetailViewModel(
            firestoreHelper: mock,
            betID: "betID",
            parentTab: .bets,
            userInvolvement: .uninvolved
        )
        
        sampleBet = Bet(
            type: .spread,
            betID: "betID",
            title: "title",
            team1: nil,
            team2: nil,
            stake: Drinks(beers: 1, shots: 1),
            dateOpened: Date.init().timeIntervalSince1970,
            dueDate: Date.init().timeIntervalSince1970 + 10000
        )
    }
    
    override func tearDown() {
        sut = nil
        mock = nil
        sampleBet = nil
        super.tearDown()
    }
    
    func test_InvolvementStatusDoesNotChangeWithNoBet() {
        sut.checkInvolvementStatus()
        XCTAssertEqual(BetInvolvementType.uninvolved, sut.userInvolvement)
    }
    
    func test_betRead() {
        // passBetToSUT() in future tests consists of these two lines
        sut.fetchBet()
        mock.betCompletion(sampleBet) // completion handler from readBet
        
        XCTAssertEqual(sampleBet.betID, sut.bet!.betID)
        XCTAssertEqual(mock.betReads, 1)
    }
    
    func test_setBetListener() {
        sut.setBetListener()
        mock.betCompletion(sampleBet)
        
        XCTAssertEqual(sampleBet.betID, sut.bet!.betID)
        XCTAssertEqual(mock.betDetailListeners, 1)
    }
    
    func test_clearBetDetailListener() {
        sut.setBetListener()
        XCTAssertEqual(mock.betDetailListeners, 1)
        sut.clearBetDetailListeners()
        XCTAssertEqual(mock.betDetailListeners, 0)
    }
    
    // MARK:- Bet Involvement Status tests
    func test_checkInvitedStatus() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        
        passBetToSUT(sampleBet)
        
        XCTAssertEqual(sut.userInvolvement, .invited)
    }
    
    func test_checkSide1AcceptedStatus() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        sampleBet.perform(action: .addToSide1, withID: uid, firstName: firstName)
        
        passBetToSUT(sampleBet)
        
        XCTAssertEqual(sut.userInvolvement, .accepted)
    }
    
    func test_checkSide2AcceptedStatus() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        sampleBet.perform(action: .addToSide2, withID: uid, firstName: firstName)
        
        passBetToSUT(sampleBet)
        
        XCTAssertEqual(sut.userInvolvement, .accepted)
    }
    
    func test_checkSide1OutstandingStatus() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        sampleBet.perform(action: .addToSide1, withID: uid, firstName: firstName)
        sampleBet.closeBetWith(winningSide: .two)
        
        passBetToSUT(sampleBet)
        
        XCTAssertEqual(sut.userInvolvement, .outstanding)
    }
    
    func test_checkSide2OutstandingStatus() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        sampleBet.perform(action: .addToSide2, withID: uid, firstName: firstName)
        sampleBet.closeBetWith(winningSide: .one)
        
        passBetToSUT(sampleBet)
        
        XCTAssertEqual(sut.userInvolvement, .outstanding)
    }
    
    func test_checkSide1FinishedAfterFulfillingLostBetStatus() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        sampleBet.perform(action: .addToSide1, withID: uid, firstName: firstName)
        sampleBet.closeBetWith(winningSide: .two)
        sampleBet.fulfill(forUser: uid)
        
        passBetToSUT(sampleBet)
        
        XCTAssertEqual(sut.userInvolvement, .closed)
    }
    
    func test_checkSide2FinishedAfterFulfillingLostBetStatus() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        sampleBet.perform(action: .addToSide2, withID: uid, firstName: firstName)
        sampleBet.closeBetWith(winningSide: .one)
        sampleBet.fulfill(forUser: uid)
        
        passBetToSUT(sampleBet)
        
        XCTAssertEqual(sut.userInvolvement, .closed)
    }
    
    func test_checkSide1WinningBetStatus() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        sampleBet.perform(action: .addToSide1, withID: uid, firstName: firstName)
        sampleBet.closeBetWith(winningSide: .one)
        
        passBetToSUT(sampleBet)
        
        XCTAssertEqual(sut.userInvolvement, .closed)
    }
    
    func test_checkSide2WinningBetStatus() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        sampleBet.perform(action: .addToSide2, withID: uid, firstName: firstName)
        sampleBet.closeBetWith(winningSide: .two)
        
        passBetToSUT(sampleBet)
        
        XCTAssertEqual(sut.userInvolvement, .closed)
    }
    
    
    // MARK:- Bet manipulation tests
    func test_acceptBet() {
        for side in Side.allCases {
            // Given an invited bet
            sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
            
            passBetToSUT(sampleBet)
            sut.acceptBet(side: side)
            
            XCTAssertNil(sut.bet!.invitedUsers[uid])
            XCTAssertTrue(sut.bet!.acceptedUsers.contains(uid))
            switch side {
            case .one:
                XCTAssertEqual(sut.bet!.side1Users, userDict)
            case .two:
                XCTAssertEqual(sut.bet!.side2Users, userDict)
            }
        }
        XCTAssertEqual(mock.betUpdates, Side.allCases.count)
        XCTAssertEqual(mock.betUpdateIncrements, 2)
        XCTAssertEqual(sut.userInvolvement, .accepted)
    }
    
    func test_acceptBetReturnsIfNoUser() {
        passBetToSUT(sampleBet)
        mock.currentUser = nil
        sut.acceptBet(side: .one)
        XCTAssertEqual(mock.betUpdates, 0)
        XCTAssertEqual(mock.betUpdateIncrements, 0)
    }
    
    func test_acceptBetReturnsIfWrongInvolvementStatus() {
        passBetToSUT(sampleBet)
        XCTAssertEqual(sut.userInvolvement, .uninvolved)
        sut.acceptBet(side: .one)
        XCTAssertEqual(mock.betUpdates, 0)
        XCTAssertEqual(mock.betUpdateIncrements, 0)
    }

    
    func test_uninvitedJoinBet() {
        for side in Side.allCases {
            passBetToSUT(sampleBet)
            sut.uninvitedJoinBet(side: side)
            
            XCTAssertTrue(sut.bet!.acceptedUsers.contains(uid))
            switch side {
            case .one:
                XCTAssertEqual(sut.bet!.side1Users, userDict)
            case .two:
                XCTAssertEqual(sut.bet!.side2Users, userDict)
            }
        }
        XCTAssertEqual(mock.betUpdates, Side.allCases.count)
        XCTAssertEqual(mock.betUpdateIncrements, 2)
        XCTAssertEqual(sut.userInvolvement, .accepted)
    }
    
    func test_uninvitedJoinBetReturnsIfNoUser() {
        passBetToSUT(sampleBet)
        mock.currentUser = nil
        sut.uninvitedJoinBet(side: .one)
        XCTAssertEqual(mock.betUpdates, 0)
        XCTAssertEqual(mock.betUpdateIncrements, 0)
    }
    
    func test_uninvitedJoinBetReturnsIfWrongInvolvementStatus() {
        // Given an invited bet
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        passBetToSUT(sampleBet)
        XCTAssertEqual(sut.userInvolvement, .invited)
        
        sut.uninvitedJoinBet(side: .one)
        XCTAssertEqual(mock.betUpdates, 0)
        XCTAssertEqual(mock.betUpdateIncrements, 0)
    }
    
    func test_rejectBet() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        passBetToSUT(sampleBet)
        sut.rejectBet()
        
        XCTAssertNil(sut.bet!.invitedUsers[uid])
        XCTAssertEqual(mock.betUpdates, 1)
        XCTAssertEqual(sut.userInvolvement, .uninvolved)
    }
    
    func test_rejectBetReturnsIfNoUser() {
        passBetToSUT(sampleBet)
        mock.currentUser = nil
        sut.rejectBet()
        XCTAssertEqual(mock.betUpdates, 0)
        XCTAssertEqual(mock.betUpdateIncrements, 0)
    }
    
    func test_rejectBetReturnsIfWrongInvolvementStatus() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        sampleBet.perform(action: .addToSide1, withID: uid, firstName: firstName)
        passBetToSUT(sampleBet)
        XCTAssertEqual(sut.userInvolvement, .accepted)
        
        sut.rejectBet()
        XCTAssertEqual(mock.betUpdates, 0)
        XCTAssertEqual(mock.betUpdateIncrements, 0)
    }
    
    func test_closeBet() {
        var alreadyClosedClosureCalls = 0
        sut.betAlreadyClosed = {
            alreadyClosedClosureCalls += 1
        }
        
        for side in Side.allCases {
            passBetToSUT(sampleBet)
            sut.uninvitedJoinBet(side: side)
            sut.closeBet(withWinner: side)
            mock.optionalBetCompletion?(sampleBet) 
        }
        
        XCTAssertEqual(alreadyClosedClosureCalls, 0)
        XCTAssertEqual(mock.betCloses, Side.allCases.count)
    }
    
    func test_closeBetReturnsIfWrongInvolvementStatus() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        passBetToSUT(sampleBet)
        XCTAssertEqual(sut.userInvolvement, .invited)
        
        sut.closeBet(withWinner: .one)
        XCTAssertEqual(mock.betCloses, 0)
        XCTAssertEqual(mock.betUpdateIncrements, 0)
    }
    
    func test_closeBetReturnsIfNilBet() {
        sut.closeBet(withWinner: .one)
        XCTAssertEqual(mock.betCloses, 0)
        XCTAssertEqual(mock.betUpdateIncrements, 0)
    }
    
    func test_alreadyClosedBet() {
        var alreadyClosedClosureCalls = 0
        sut.betAlreadyClosed = {
            alreadyClosedClosureCalls += 1
        }
        
        sampleBet.setBetID(withID: "alreadyClosed")
        for side in Side.allCases {
            passBetToSUT(sampleBet)
            sut.uninvitedJoinBet(side: side)
            sut.closeBet(withWinner: side)
            mock.optionalBetCompletion?(sampleBet)
        }
        
        XCTAssertEqual(alreadyClosedClosureCalls, 2)
        XCTAssertEqual(mock.betCloses, 0)
    }
    
    func test_unjoinBet() {
        passBetToSUT(sampleBet)
        for side in Side.allCases {
            sut.uninvitedJoinBet(side: side)
            XCTAssertEqual(mock.betUpdateIncrements, 1)
            sut.unjoinBet()
            XCTAssertFalse(sut.bet!.acceptedUsers.contains(uid))
            
            switch side {
            case .one:
                XCTAssertNil(sut.bet!.side1Users[uid])
            case .two:
                XCTAssertNil(sut.bet!.side2Users[uid])
            }
        }
        
        XCTAssertEqual(mock.betUpdates, Side.allCases.count * 2)
        // Unjoining bets resets bet count to 0
        XCTAssertEqual(mock.betUpdateIncrements, 0)
    }
    
    func test_unjoinBetReturnsIfNoUser() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        sampleBet.perform(action: .addToSide1, withID: uid, firstName: firstName)
        passBetToSUT(sampleBet)
        XCTAssertEqual(sut.userInvolvement, .accepted)
        mock.currentUser = nil
        
        sut.unjoinBet()
        XCTAssertEqual(mock.betUpdates, 0)
        XCTAssertEqual(mock.betUpdateIncrements, 0)
    }
    
    func test_unjoinBetReturnsIfWrongInvolvementStatus() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        passBetToSUT(sampleBet)
        XCTAssertEqual(sut.userInvolvement, .invited)
        
        sut.unjoinBet()
        XCTAssertEqual(mock.betUpdates, 0)
        XCTAssertEqual(mock.betUpdateIncrements, 0)
    }


    func test_deleteBet() {
        sut.fetchBet()
        mock.betCompletion(sampleBet)
        sut.deleteBet()
        
        XCTAssertEqual(mock.betDeletes, 1)
        XCTAssertEqual(mock.betUpdateIncrements, -1)
    }
    
    func test_deleteBetReturnsIfNilBet() {
        sut.deleteBet()
        XCTAssertEqual(mock.betDeletes, 0)
    }
    
    func test_fulfillBet() {
        for side in Side.allCases {
            // Set bet status to outstanding
            sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
            switch side {
            case .one:
                sampleBet.perform(action: .addToSide1, withID: uid, firstName: firstName)
                sampleBet.closeBetWith(winningSide: .two)
                passBetToSUT(sampleBet)
                sut.fulfillBet()
            case .two:
                sampleBet.perform(action: .addToSide2, withID: uid, firstName: firstName)
                sampleBet.closeBetWith(winningSide: .one)
                passBetToSUT(sampleBet)
                sut.fulfillBet()
            }
        }
        
        XCTAssertEqual(mock.betUpdates, Side.allCases.count)
        XCTAssertEqual(mock.betFulfillIncrements, Side.allCases.count)
    }
    
    func test_fulfillBetReturnsIfWrongInvolvementStatus() {
        for side in Side.allCases {
            sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
            switch side {
            case .one:
                sampleBet.perform(action: .addToSide1, withID: uid, firstName: firstName)
                sampleBet.closeBetWith(winningSide: .one)
                passBetToSUT(sampleBet)
                sut.fulfillBet()
            case .two:
                sampleBet.perform(action: .addToSide2, withID: uid, firstName: firstName)
                sampleBet.closeBetWith(winningSide: .two)
                passBetToSUT(sampleBet)
                sut.fulfillBet()
            }
        }
        
        XCTAssertEqual(mock.betUpdates, 0)
        XCTAssertEqual(mock.betFulfillIncrements, 0)
    }
    
    func test_fulfillBetReturnsIfNilUser() {
        mock.currentUser = nil
        sut.fulfillBet()
        XCTAssertEqual(mock.betUpdates, 0)
        XCTAssertEqual(mock.betFulfillIncrements, 0)
    }
    
    
    
    // MARK:- Messaging method tests
   
    func test_setMessageListener() {
        // set to accepted status
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        sampleBet.perform(action: .addToSide1, withID: uid, firstName: firstName)
        passBetToSUT(sampleBet)
        
        // Listener is set in sut.bet's didSet
        XCTAssertEqual(mock.messageListeners, 1)
    }
    
    func test_setMessageListenerFails() {
        passBetToSUT(sampleBet) // uninvolved status
        
        XCTAssertEqual(mock.messageListeners, 0)
    }
    
    func test_sendMessage() {
        passBetToSUT(sampleBet)
        let randomNumber = Int.random(in: 1...10)
        
        for _ in 1...randomNumber {
            sut.sendMessage(with: "string")
        }
        XCTAssertEqual(mock.messagesSent, randomNumber)
    }
    
    func test_messageDoesNotSendIfNoBet() {
        sut.sendMessage(with: "string")
        XCTAssertEqual(mock.messagesSent, 0)
    }
    
    func test_messageCellVMCreation() {
        let sampleMessages: [Message] = [
            Message(uid: "uid", firstName: "firstName", body: "1", timestamp: 0),
            Message(uid: "me", firstName: "firstName", body: "2", timestamp: 0),
            Message(uid: "you", firstName: "firstName", body: "3", timestamp: 0),
            Message(uid: "you", firstName: "firstName", body: "4", timestamp: 0),
            Message(uid: "you", firstName: "firstName", body: "4", timestamp: 0),
            Message(uid: "me", firstName: "firstName", body: "2", timestamp: 0)
        ]
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        sampleBet.perform(action: .addToSide1, withID: uid, firstName: firstName)
        passBetToSUT(sampleBet)
        
        // Get messages
        mock.messagesCompletion(sampleMessages)
        
        
        XCTAssertEqual(sut.messageCellVMs.count, sampleMessages.count)
        XCTAssertTrue(sut.messageCellVMs.first!.isMessageFromSelf)
        XCTAssertFalse(sut.messageCellVMs[1].isMessageFromSelf)
        XCTAssertFalse(sut.messageCellVMs[2].isMessageFromSelf)
        XCTAssertFalse(sut.messageCellVMs[2].isPreviousMessageFromSameSender)
        XCTAssertTrue(sut.messageCellVMs[3].isPreviousMessageFromSameSender)
        XCTAssertTrue(sut.messageCellVMs[4].isPreviousMessageFromSameSender)
        XCTAssertFalse(sut.messageCellVMs.last!.isPreviousMessageFromSameSender)
    }
    
    
    // MARK:- Display string parsing tests
    func test_getNilBetLine() {
        XCTAssertNil(sut.getBetLine())
    }
    
    func test_getNilLine() {
        passBetToSUT(sampleBet)
        XCTAssertNil(sut.getBetLine())
    }
    
    func test_getLine() {
        let userInputValues = [0, 0.5000, 012.583929, 00002.000001, 0.1205738298, 120, 2.0]
        let expectedStrings = ["0", "0.5", "12.6", "2.0", "0.1", "120", "2"]
        
        for i in 0..<userInputValues.count {
            sampleBet.line = userInputValues[i]
            passBetToSUT(sampleBet)
            
            XCTAssertEqual(sut.getBetLine(), expectedStrings[i])
        }
    }
    
    func test_getNilBetSideNames() {
        XCTAssertNil(sut.getSideNames(forSide: .one))
        XCTAssertNil(sut.getSideNames(forSide: .two))
    }
    
    func test_getSideNamesFromBetWithNoUsers() {
        passBetToSUT(sampleBet)
        XCTAssertEqual(sut.getSideNames(forSide: .one), "")
        XCTAssertEqual(sut.getSideNames(forSide: .two), "")
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
        
        passBetToSUT(bet)
        
        let possibleCombos = ["a, b", "b, a"]
        
        XCTAssertTrue(possibleCombos.contains(sut.getSideNames(forSide: .one)!))
        XCTAssertEqual(sut.getSideNames(forSide: .two), "c")
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
                "9": "j"
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
        let side1Count = bet.side1Users.count
        let side2Count = bet.side2Users.count
        passBetToSUT(bet)
        
        XCTAssertEqual("\(side1Count) people", sut.getSideNames(forSide: .one))
        XCTAssertEqual("\(side2Count) people", sut.getSideNames(forSide: .two))
    }
    
    func test_getDateString() {
        sampleBet.dueDate = 0
        passBetToSUT(sampleBet)
        
        XCTAssertEqual(sut.getDateString(), "12/31/69")
        
        sampleBet.dueDate = 1610065513
        passBetToSUT(sampleBet)
        
        XCTAssertEqual(sut.getDateString(), "1/7/21")
    }
    
    func test_getNilBetDate() {
        XCTAssertNil(sut.getDateString())
    }
    
    func test_getNilBetStakeString() {
        XCTAssertNil(sut.getStakeString())
    }
    
    func test_getStakeString() {
        let randomNumber1 = Int.random(in: -100000...100000)
        let randomNumber2 = Int.random(in: -100000...100000)
        sampleBet.stake = Drinks(beers: randomNumber1, shots: randomNumber2)
        passBetToSUT(sampleBet)
        
        XCTAssertEqual(sut.getStakeString(), "\(randomNumber1) 🍺 \(randomNumber2) 🥃")
        
    }
    
    func test_getNilBetStatus() {
        XCTAssertEqual(sut.getBetStatusAndColor().label, "")
        XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.orange)
    }
    
    func test_getInPlayBetStatus() {
        passBetToSUT(sampleBet)
        XCTAssertEqual(sut.getBetStatusAndColor().label, "IN PLAY")
        XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.orange)
    }
    
    func test_getOverdueBetStatus() {
        sampleBet.dueDate = 0
        passBetToSUT(sampleBet)
        XCTAssertEqual(sut.getBetStatusAndColor().label, "OVERDUE")
        XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.burntUmber)
    }
    
    func test_getOutstandingBetStatus() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        for side in Side.allCases {
            switch side {
            case .one:
                var bet = sampleBet!
                bet.perform(action: .addToSide1, withID: uid, firstName: firstName)
                bet.closeBetWith(winningSide: .two)
                passBetToSUT(bet)
                XCTAssertEqual(sut.getBetStatusAndColor().label, "OUTSTANDING")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.burntUmber)
            case .two:
                var bet = sampleBet!
                bet.perform(action: .addToSide2, withID: uid, firstName: firstName)
                bet.closeBetWith(winningSide: .one)
                passBetToSUT(bet)
                XCTAssertEqual(sut.getBetStatusAndColor().label, "OUTSTANDING")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.burntUmber)
            }
        }
    }
    
    func test_getUserWonBetStatus() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        for side in Side.allCases {
            switch side {
            case .one:
                var bet = sampleBet!
                bet.perform(action: .addToSide1, withID: uid, firstName: firstName)
                bet.closeBetWith(winningSide: .one)
                passBetToSUT(bet)
                XCTAssertEqual(sut.getBetStatusAndColor().label, "YOU WON")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.forestGreen)
            case .two:
                var bet = sampleBet!
                bet.perform(action: .addToSide2, withID: uid, firstName: firstName)
                bet.closeBetWith(winningSide: .two)
                passBetToSUT(bet)
                XCTAssertEqual(sut.getBetStatusAndColor().label, "YOU WON")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.forestGreen)
            }
        }
    }
    
    func test_getUserLostBetStatus() {
        sampleBet.perform(action: .invite, withID: uid, firstName: firstName)
        for side in Side.allCases {
            switch side {
            case .one:
                var bet = sampleBet!
                bet.perform(action: .addToSide1, withID: uid, firstName: firstName)
                bet.closeBetWith(winningSide: .two)
                bet.fulfill(forUser: uid)
                passBetToSUT(bet)
                XCTAssertEqual(sut.getBetStatusAndColor().label, "YOU LOST")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.burntUmber)
            case .two:
                var bet = sampleBet!
                bet.perform(action: .addToSide2, withID: uid, firstName: firstName)
                bet.closeBetWith(winningSide: .one)
                bet.fulfill(forUser: uid)
                passBetToSUT(bet)
                XCTAssertEqual(sut.getBetStatusAndColor().label, "YOU LOST")
                XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.burntUmber)
            }
        }
    }
    
    func test_getUninvolvedClosedBetStatus() {
        for type in BetType.allCases {
            sampleBet.type = type
            switch type {
            case .spread:
                for side in Side.allCases {
                    var bet = sampleBet!
                    bet.closeBetWith(winningSide: side)
                    passBetToSUT(bet)
                    switch side {
                    case .one:
                        XCTAssertEqual(sut.getBetStatusAndColor().label, "OVER")
                        XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.midBlue)
                    case .two:
                        XCTAssertEqual(sut.getBetStatusAndColor().label, "UNDER")
                        XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.midBlue)
                    }
                }
            case .moneyline:
                sampleBet.team1 = "team1"
                sampleBet.team2 = "team2"
                for side in Side.allCases {
                    var bet = sampleBet!
                    bet.closeBetWith(winningSide: side)
                    passBetToSUT(bet)
                    switch side {
                    case .one:
                        XCTAssertEqual(sut.getBetStatusAndColor().label, "TEAM1")
                        XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.midBlue)
                    case .two:
                        XCTAssertEqual(sut.getBetStatusAndColor().label, "TEAM2")
                        XCTAssertEqual(sut.getBetStatusAndColor().color, K.colors.midBlue)
                    }
                }
            case .event:
                for side in Side.allCases {
                    var bet = sampleBet!
                    bet.closeBetWith(winningSide: side)
                    passBetToSUT(bet)
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
        }
    }
    
    func test_getButtonStrings() {
        for type in BetType.allCases {
            sampleBet.type = type
            switch type {
            case .spread:
                passBetToSUT(sampleBet)
                XCTAssertEqual(sut.getButtonStrings().side1, "TAKE THE OVER")
                XCTAssertEqual(sut.getButtonStrings().side2, "TAKE THE UNDER")
            case .moneyline:
                sampleBet.team1 = "team1"
                sampleBet.team2 = "team2"
                passBetToSUT(sampleBet)
                XCTAssertEqual(sut.getButtonStrings().side1, "TEAM1")
                XCTAssertEqual(sut.getButtonStrings().side2, "TEAM2")
            case .event:
                passBetToSUT(sampleBet)
                XCTAssertEqual(sut.getButtonStrings().side1, "FOR")
                XCTAssertEqual(sut.getButtonStrings().side2, "AGAINST")
            }
        }
    }
    
    func test_getActionSheetStrings() {
        for type in BetType.allCases {
            sampleBet.type = type
            switch type {
            case .spread:
                passBetToSUT(sampleBet)
                XCTAssertEqual(sut.getActionSheetStrings().side1, "Over")
                XCTAssertEqual(sut.getActionSheetStrings().side2, "Under")
            case .moneyline:
                sampleBet.team1 = "team1"
                sampleBet.team2 = "team2"
                passBetToSUT(sampleBet)
                XCTAssertEqual(sut.getActionSheetStrings().side1, "team1")
                XCTAssertEqual(sut.getActionSheetStrings().side2, "team2")
            case .event:
                passBetToSUT(sampleBet)
                XCTAssertEqual(sut.getActionSheetStrings().side1, "For")
                XCTAssertEqual(sut.getActionSheetStrings().side2, "Against")
            }
        }
    }
    
}


// MARK:- Helper methods
extension BetDetailViewModelTests {
    
    func passBetToSUT(_ bet: Bet) {
        sut.fetchBet()
        mock.betCompletion(bet)
    }
}
