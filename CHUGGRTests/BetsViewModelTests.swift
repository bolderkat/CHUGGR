//
//  BetsViewModelTests.swift
//  CHUGGRTests
//
//  Created by Daniel Luo on 1/8/21.
//

import XCTest
@testable import CHUGGR

class BetsViewModelTests: XCTestCase {

    private var sut: BetsViewModel!
    private var mock: MockFirestoreHelper!
    var pendingBetClosureCalls = 0
    var betCellUpdateClosureCalls = 0
    var loadingStatusClosureCalls = 0
    var sampleBets: [Bet]!
    
    override func setUp() {
        super.setUp()
        // GIVEN: 2 each of invited, outstanding, and accepted bets, 3 uninvolved bets
        sampleBets = [
            Bet(
                type: .spread,
                betID: "betID0",
                title: "title",
                line: 8.8,
                team1: nil,
                team2: nil,
                invitedUsers: ["uid": "firstName"],
                allUsers: Set<String>(["uid"]),
                stake: Drinks(beers: 1, shots: 1),
                dateOpened: Date.init().timeIntervalSince1970 - 4000,
                dueDate: Date.init().timeIntervalSince1970 + 10000
            ),
            Bet(
                type: .moneyline,
                betID: "betID1",
                title: "title",
                team1: "team1",
                team2: "team2",
                invitedUsers: ["uid": "firstName"],
                allUsers: Set<String>(["uid"]),
                stake: Drinks(beers: 1, shots: 1),
                dateOpened: Date.init().timeIntervalSince1970 - 3000,
                dueDate: Date.init().timeIntervalSince1970 + 10000
            ),
            Bet(
                type: .event,
                betID: "betID2",
                title: "title",
                line: nil,
                team1: nil,
                team2: nil,
                invitedUsers: [:],
                side1Users: ["uid": "firstName"],
                side2Users: [:],
                outstandingUsers: Set<String>(["uid"]),
                allUsers: Set<String>(["uid"]),
                acceptedUsers: Set<String>(["uid"]),
                stake: Drinks(beers: 1, shots: 1),
                dateOpened: Date.init().timeIntervalSince1970 - 1000,
                dueDate: Date.init().timeIntervalSince1970 + 10000,
                isFinished: false,
                winner: .two,
                dateFinished: Date.init().timeIntervalSince1970
            ),
            Bet(
                type: .event,
                betID: "betID3",
                title: "title",
                line: nil,
                team1: nil,
                team2: nil,
                invitedUsers: [:],
                side1Users: ["uid": "firstName"],
                side2Users: [:],
                outstandingUsers: Set<String>(["uid"]),
                allUsers: Set<String>(["uid"]),
                acceptedUsers: Set<String>(["uid"]),
                stake: Drinks(beers: 1, shots: 1),
                dateOpened: Date.init().timeIntervalSince1970 - 100,
                dueDate: Date.init().timeIntervalSince1970 + 10000,
                isFinished: false,
                winner: .two,
                dateFinished: Date.init().timeIntervalSince1970
            ),
            Bet(
                type: .event,
                betID: "betID4",
                title: "title",
                line: nil,
                team1: nil,
                team2: nil,
                invitedUsers: [:],
                side1Users: ["uid": "firstName"],
                side2Users: [:],
                outstandingUsers: Set<String>(),
                allUsers: Set<String>(["uid"]),
                acceptedUsers: Set<String>(["uid"]),
                stake: Drinks(beers: 1, shots: 1),
                dateOpened: Date.init().timeIntervalSince1970 - 10,
                dueDate: Date.init().timeIntervalSince1970 + 10000,
                isFinished: false
            ),
            Bet(
                type: .event,
                betID: "betID5",
                title: "title",
                line: nil,
                team1: nil,
                team2: nil,
                invitedUsers: [:],
                side1Users: ["uid": "firstName"],
                side2Users: [:],
                outstandingUsers: Set<String>(),
                allUsers: Set<String>(["uid"]),
                acceptedUsers: Set<String>(["uid"]),
                stake: Drinks(beers: 1, shots: 1),
                dateOpened: Date.init().timeIntervalSince1970 - 9,
                dueDate: Date.init().timeIntervalSince1970 + 10000,
                isFinished: false
            ),
            Bet(
                type: .event,
                betID: "betID6",
                title: "title",
                team1: nil,
                team2: nil,
                stake: Drinks(beers: 1, shots: 1),
                dateOpened: Date.init().timeIntervalSince1970 - 8,
                dueDate: Date.init().timeIntervalSince1970 + 10000
            ),
            Bet(
                type: .event,
                betID: "betID7",
                title: "title",
                team1: nil,
                team2: nil,
                stake: Drinks(beers: 1, shots: 1),
                dateOpened: Date.init().timeIntervalSince1970 - 7,
                dueDate: Date.init().timeIntervalSince1970 + 10000
            ),
            Bet(
                type: .event,
                betID: "betID8",
                title: "title",
                team1: nil,
                team2: nil,
                stake: Drinks(beers: 1, shots: 1),
                dateOpened: Date.init().timeIntervalSince1970 - 6,
                dueDate: Date.init().timeIntervalSince1970 + 10000
            ),
        ]
        pendingBetClosureCalls = 0
        betCellUpdateClosureCalls = 0
        loadingStatusClosureCalls = 0
        mock = MockFirestoreHelper()
        mock.sampleBets = sampleBets
        sut = BetsViewModel(firestoreHelper: mock)
        
        sut.didUpdatePendingBets = { [weak self] in
            self?.pendingBetClosureCalls += 1
        }
        
        sut.didUpdateBetCellVMs = { [weak self] in
            self?.betCellUpdateClosureCalls += 1
        }
        
        sut.didChangeLoadingStatus = { [weak self] in
            self?.loadingStatusClosureCalls += 1
        }
    }
    
    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }
    
    func test_initFetchBets() {
        sut.initFetchBets()
        XCTAssertEqual(sut.pendingBets.count, 2)
        XCTAssertEqual(sut.userInvolvedBets.count, 4)
        XCTAssertEqual(sut.userInvolvedBetCellVMs.count, 4)
        XCTAssertEqual(sut.otherBets.count, 2)
        XCTAssertEqual(sut.otherBetCellVMs.count, 2)
        XCTAssertEqual(pendingBetClosureCalls, 1)
        XCTAssertEqual(betCellUpdateClosureCalls, 2)
        XCTAssertEqual(sut.pendingBets[0].betID, "betID0")
        XCTAssertEqual(sut.pendingBets[1].betID, "betID1")
        
        for i in 2...5 {
            XCTAssertEqual(sut.userInvolvedBets[i-2].betID, "betID\(i)")
        }
        
        XCTAssertEqual(sut.otherBets[0].betID, "betID6")
        XCTAssertEqual(sut.otherBets[1].betID, "betID7")
        XCTAssertEqual(sut.isLoading, false)
        
    }
    
    func test_initInvolvedBetFetchReturnsIfNoUser() {
        mock.currentUser = nil
        sut.initFetchBets()
        XCTAssertEqual(sut.pendingBets.count, 0)
        XCTAssertEqual(sut.userInvolvedBets.count, 0)
        XCTAssertEqual(sut.userInvolvedBetCellVMs.count, 0)
        XCTAssertEqual(sut.otherBets.count, 2)
        XCTAssertEqual(sut.otherBetCellVMs.count, 2)
        XCTAssertEqual(pendingBetClosureCalls, 0)
        XCTAssertEqual(betCellUpdateClosureCalls, 1)
        XCTAssertEqual(sut.isLoading, false)
    }
    
    func test_isolatedLoadAdditionalBets() {
        sut.loadAdditionalBets()
        XCTAssertEqual(sut.otherBets.count, 1)
        XCTAssertEqual(sut.otherBetCellVMs.count, 1)
        XCTAssertEqual(betCellUpdateClosureCalls, 1)
        XCTAssertEqual(sut.otherBets[0].betID, "betID8")
        XCTAssertEqual(sut.isLoading, false)
    }
    
    func test_subsequentLoadAdditionalBets() {
        sut.initFetchBets()
        sut.loadAdditionalBets()
        XCTAssertEqual(sut.pendingBets.count, 2)
        XCTAssertEqual(sut.userInvolvedBets.count, 4)
        XCTAssertEqual(sut.userInvolvedBetCellVMs.count, 4)
        XCTAssertEqual(sut.otherBets.count, 3)
        XCTAssertEqual(sut.otherBetCellVMs.count, 3)
        XCTAssertEqual(pendingBetClosureCalls, 1)
        XCTAssertEqual(betCellUpdateClosureCalls, 3)
        XCTAssertEqual(sut.pendingBets[0].betID, "betID0")
        XCTAssertEqual(sut.pendingBets[1].betID, "betID1")
        
        for i in 2...5 {
            XCTAssertEqual(sut.userInvolvedBets[i-2].betID, "betID\(i)")
        }
        
        XCTAssertEqual(sut.otherBets[0].betID, "betID6")
        XCTAssertEqual(sut.otherBets[1].betID, "betID7")
        XCTAssertEqual(sut.otherBets[2].betID, "betID8")
        XCTAssertEqual(sut.isLoading, false)
    }
    
    func test_getCellVMWithAllBetTypes() {
        sut.initFetchBets()
        sut.loadAdditionalBets()
        let indexPath0 = IndexPath(row: 0, section: 0)
        let indexPath1 = IndexPath(row: 0, section: 1)
        let firstInvolvedBetVM = sut.getCellVM(at: indexPath0)
        let firstOtherBetVM = sut.getCellVM(at: indexPath1)
        
        XCTAssertEqual(firstInvolvedBetVM.bet.betID, "betID2")
        XCTAssertEqual(firstOtherBetVM.bet.betID, "betID6")
    }
    
    func test_getCellVMWithNoInvolvedBets() {
        // Remove involved bets
        for _ in 1...4 {
            mock.sampleBets.remove(at: 2)
        }
        sut.initFetchBets()
        sut.loadAdditionalBets()
        
        for i in 0...2 {
            let indexPath = IndexPath(row: i, section: 0)
            let betVM = sut.getCellVM(at: indexPath)
            XCTAssertEqual(betVM.bet.betID, "betID\(i + 6)")
        }
    }
    
    func test_getCellVMWithNoUninvolvedBets() {
        // Remove uninvolved bets
        for _ in 1...3 {
            mock.sampleBets.remove(at: 6)
        }
        sut.initFetchBets()
        sut.loadAdditionalBets()
        
        for i in 0...3 {
            let indexPath = IndexPath(row: i, section: 0)
            let betVM = sut.getCellVM(at: indexPath)
            XCTAssertEqual(betVM.bet.betID, "betID\(i + 2)")
        }
    }
    
    func test_getPendingBetsLabelNoBets() {
        // Remove pending bets
        mock.sampleBets.remove(at: 0)
        mock.sampleBets.remove(at: 0)
        sut.initFetchBets()
        XCTAssertEqual(sut.getPendingBetsLabel(), "No bets pending")
    }
    
    func test_getPendingBetsLabelOneBet() {
        // Remove pending bets
        mock.sampleBets.remove(at: 0)
        sut.initFetchBets()
        XCTAssertEqual(sut.getPendingBetsLabel(), "1 new bet pending!")
    }
    
    func test_getPendingBetsLabelTwoBets() {
        // Remove pending bets
        sut.initFetchBets()
        XCTAssertEqual(sut.getPendingBetsLabel(), "2 new bets pending!")
    }
    
    func test_getPendingBetsStake() {
        sut.initFetchBets()
        XCTAssertEqual(sut.getPendingBetsStake(), "2 🍺 2 🥃")
    }

}
