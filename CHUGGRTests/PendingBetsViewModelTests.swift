//
//  PendingBetsViewModelTests.swift
//  CHUGGRTests
//
//  Created by Daniel Luo on 1/12/21.
//

import XCTest
@testable import CHUGGR

class PendingBetsViewModelTests: XCTestCase {

    var sut: PendingBetsViewModel!
    var mock: MockFirestoreHelper!
    let sampleBets = [
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
    var updateClosureCount = 0
    
    override func setUp() {
        super.setUp()
        mock = MockFirestoreHelper()
        mock.sampleBets = sampleBets
        
        // Bets VM will have fetched bets before user gets to pending bets
        let betsVM = BetsViewModel(firestoreHelper: mock)
        betsVM.initFetchBets()
        sut = PendingBetsViewModel(firestoreHelper: mock)
        sut.didUpdateBetCellVMs = { [weak self] in
            self?.updateClosureCount += 1
        }
        updateClosureCount = 0
    }
    
    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }
    
    func test_fetchPendingBets() {
        sut.fetchPendingBets()
        XCTAssertEqual(sut.betCellVMs.count, 2)
        XCTAssertEqual(updateClosureCount, 1)
    }
    
    func test_fetchPendingBetsReturnsIfNilUser() {
        mock.currentUser = nil
        sut.fetchPendingBets()
        XCTAssertEqual(sut.betCellVMs.count, 0)
        XCTAssertEqual(updateClosureCount, 0)
    }
    
    func test_getCellVMs() {
        sut.fetchPendingBets()
        for i in 0..<sut.betCellVMs.count {
            let indexPath = IndexPath(row: i, section: 0)
            let vm = sut.getCellVM(at: indexPath)
            XCTAssertEqual(vm.bet.betID, sampleBets[i].betID)
        }
    }
    
    
    
    
    
}
