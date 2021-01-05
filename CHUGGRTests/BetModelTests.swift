//
//  BetModelTests.swift
//  CHUGGRTests
//
//  Created by Daniel Luo on 12/12/20.
//

@testable import CHUGGR
import XCTest

class BetModelTests: XCTestCase {
    
    var sut: Bet!
    let fname = "daniel"
    let uid = "uid"
    
    override func setUp() {
        super.setUp()
        sut = Bet(
            type: .spread,
            betID: "betID",
            title: "bet Title",
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
    }

    

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    


    func test_InviteUser() {
        inviteUser()
        XCTAssert(sut.allUsers.contains(uid))
        XCTAssertEqual(sut.invitedUsers, [uid: fname])
    }
    
    func test_UninviteUser() {
        inviteUser()
        uninviteUser()
        XCTAssertEqual(sut.invitedUsers, [:])
        XCTAssertEqual(sut.side2Users, [:])
        XCTAssertFalse(sut.acceptedUsers.contains(uid))
        XCTAssertFalse(sut.allUsers.contains(uid))
    }
    
    func test_AddToSide1() {
        inviteUser()
        addToSide1()
        XCTAssertEqual(sut.side1Users, [uid: fname])
        XCTAssert(sut.acceptedUsers.contains(uid))
        XCTAssert(sut.allUsers.contains(uid))
    }
    
    func test_AddToSide2() {
        inviteUser()
        addToSide2()
        XCTAssertEqual(sut.side2Users, [uid: fname])
        XCTAssert(sut.acceptedUsers.contains(uid))
        XCTAssert(sut.allUsers.contains(uid))
    }
    
    func test_RemoveFromSide1() {
        inviteUser()
        addToSide1()
        remove()
        XCTAssertEqual(sut.side1Users, [:])
        XCTAssertFalse(sut.allUsers.contains(uid))
        XCTAssertFalse(sut.acceptedUsers.contains(uid))
    }
    
    func test_RemoveFromSide2() {
        inviteUser()
        addToSide2()
        remove()
        XCTAssertEqual(sut.side2Users, [:])
        XCTAssertFalse(sut.allUsers.contains(uid))
        XCTAssertFalse(sut.acceptedUsers.contains(uid))
    }
    
    func test_addUninvitedUserToSideFails() {
        addToSide2()
        XCTAssertNil(sut.side2Users[uid]) // shouldn't work because user wasn't invited
        XCTAssertEqual(sut.side2Users, [:]) // should be the same as above, just playing around
        XCTAssertEqual(sut.invitedUsers, [:])
        XCTAssertFalse(sut.acceptedUsers.contains(uid))
        XCTAssertFalse(sut.allUsers.contains(uid))
    }
    
    func test_reinviteUserAfterRemoved() {
        inviteUser()
        addToSide1()
        remove()
        inviteUser()
        XCTAssert(sut.allUsers.contains(uid))
        XCTAssertEqual(sut.invitedUsers, [uid: fname])
        XCTAssertEqual(sut.side1Users, [:])
    }
    
    func test_uninviteAcceptedUser() {
        inviteUser()
        addToSide2()
        uninviteUser()
        
        // This should not do anything, as the user has moved from invited to accepted
        XCTAssertEqual(sut.invitedUsers, [:])
        XCTAssertEqual(sut.side2Users, [uid: fname])
        XCTAssert(sut.allUsers.contains(uid))
    }
    
    
    func test_Finish()  {
        // Given winning side is one
        let winner = Side.one
        
        inviteUser()
        addToSide1()
        sut.closeBetWith(winningSide: winner)
        XCTAssertGreaterThan(sut.dateFinished!, sut.dateOpened)
        XCTAssertGreaterThanOrEqual(Date().timeIntervalSince1970, sut.dateFinished!)
        XCTAssertTrue(sut.isFinished)
        XCTAssertEqual(sut.winner, winner)
    }
}


// MARK:- Helper functions for tests

private extension BetModelTests {
    
    func inviteUser() {
        sut.perform(action: .invite, withID: uid, firstName: fname)
    }
    
    func uninviteUser() {
        sut.perform(action: .uninvite, withID: uid, firstName: fname)
    }
    
    func addToSide1() {
        sut.perform(action: .addToSide1, withID: uid, firstName: fname)
    }
    
    func addToSide2() {
        sut.perform(action: .addToSide2, withID: uid, firstName: fname)
    }
    
    func remove() {
        sut.perform(action: .removeFromSide, withID: uid, firstName: fname)
    }
    
}
