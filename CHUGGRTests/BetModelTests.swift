//
//  BetModelTests.swift
//  CHUGGRTests
//
//  Created by Daniel Luo on 12/12/20.
//

@testable import CHUGGR
import XCTest

class BetModelTests: XCTestCase {
    var bet = Bet(
        type: .spread,
        betID: "betID",
        title: "Bet Title",
        line: 6.5,
        team1: nil,
        team2: nil,
        invitedUsers: [:],
        side1Users: [:],
        side2Users: [:],
        allUsers: Set<String>(),
        acceptedUsers: Set<String>(),
        stake: Drinks(beers: 1, shots: 1),
        dateOpened: Date.init().timeIntervalSince1970,
        dueDate: Date.init().timeIntervalSince1970 + 10000,
        isFinished: false,
        winner: nil,
        dateFinished: nil
    )

    
    override func setUpWithError() throws {
    }
    

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func inviteUser() {
        bet.perform(action: .invite, withID: "uid", firstName: "daniel")
    }
    
    func uninviteUser() {
        bet.perform(action: .uninvite, withID: "uid", firstName: "daniel")
    }
    
    func addToSide1() {
        bet.perform(action: .addToSide1, withID: "uid", firstName: "daniel")
    }
    
    func addToSide2() {
        bet.perform(action: .addToSide2, withID: "uid", firstName: "daniel")
    }
    
    func remove() {
        bet.perform(action: .removeFromSide, withID: "uid", firstName: "daniel")
    }

    func testUserActions() throws {
        inviteUser()
        XCTAssertTrue(bet.allUsers.contains("uid"))
        XCTAssertEqual(bet.invitedUsers, ["uid": "daniel"])
        
        addToSide1()
        XCTAssertEqual(bet.side1Users, ["uid": "daniel"])
        XCTAssertTrue(bet.acceptedUsers.contains("uid"))
        XCTAssertTrue(bet.allUsers.contains("uid"))
        
        remove()
        XCTAssertEqual(bet.side1Users, [:])
        XCTAssertFalse(bet.allUsers.contains("uid"))
        XCTAssertFalse(bet.acceptedUsers.contains("uid"))
        
        addToSide2()
        XCTAssertNil(bet.side2Users["uid"]) // shouldn't work because user wasn't invited
        XCTAssertEqual(bet.side2Users, [:]) // should be the same as above, just playing around
        XCTAssertEqual(bet.invitedUsers, [:])
        XCTAssertFalse(bet.acceptedUsers.contains("uid"))
        XCTAssertFalse(bet.allUsers.contains("uid"))
        
        
        inviteUser()
        addToSide2()
        XCTAssertEqual(bet.side2Users, ["uid": "daniel"])
        XCTAssertTrue(bet.acceptedUsers.contains("uid"))
        XCTAssertTrue(bet.allUsers.contains("uid"))
        
        remove()
        inviteUser()
        XCTAssertTrue(bet.allUsers.contains("uid"))
        XCTAssertEqual(bet.invitedUsers, ["uid": "daniel"])
        
        uninviteUser()
        XCTAssertEqual(bet.invitedUsers, [:])
        XCTAssertEqual(bet.side2Users, [:])
        XCTAssertFalse(bet.acceptedUsers.contains("uid"))
        XCTAssertFalse(bet.allUsers.contains("uid"))
        
        // see if removing a nonexistent user breaks anything
        uninviteUser()
        remove()
        XCTAssertEqual(bet.invitedUsers, [:])
        XCTAssertEqual(bet.side1Users, [:])
        XCTAssertEqual(bet.side2Users, [:])
        XCTAssertFalse(bet.allUsers.contains("uid"))
        XCTAssertFalse(bet.acceptedUsers.contains("uid"))
    }
    
    func testFinish() throws {
        bet.perform(action: .invite, withID: "uid", firstName: "daniel")
        bet.perform(action: .addToSide1, withID: "uid", firstName: "daniel")
        bet.closeBetWith(winningSide: .one)
        XCTAssertGreaterThan(bet.dateFinished!, bet.dateOpened)
        XCTAssertGreaterThanOrEqual(Date().timeIntervalSince1970, bet.dateFinished!)
        XCTAssertTrue(bet.isFinished)
        XCTAssertEqual(bet.winner, Side.one)
    }
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
