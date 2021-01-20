//
//  ProfileViewModelTests.swift
//  CHUGGRTests
//
//  Created by Daniel Luo on 1/14/21.
//

import XCTest
@testable import CHUGGR

class ProfileViewModelTests: XCTestCase {

    var sut: ProfileViewModel!
    var mock: MockFirestoreHelper!
    var userDataChangeClosureCalls = 0
    var cellVMUpdateClosureCalls = 0
    
    override func setUp() {
        super.setUp()
        mock = MockFirestoreHelper()
        sut = ProfileViewModel(firestoreHelper: mock, user: mock.currentUser!)
        userDataChangeClosureCalls = 0
        cellVMUpdateClosureCalls = 0
        
        sut.currentUserDataDidChange = { [weak self] in
            self?.userDataChangeClosureCalls += 1
        }
        
        sut.didUpdatePastBetCells = { [weak self] in
            self?.cellVMUpdateClosureCalls += 1
        }
    }
    
    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }
    
    func test_bindUserToListener() {
        sut.bindUserToListener()
        XCTAssertEqual(userDataChangeClosureCalls, 1)
    }
    
    func test_bindUserToListenerReturnsIfUserIsNil() {
        mock.currentUser = nil
        sut.bindUserToListener()
        XCTAssertEqual(userDataChangeClosureCalls, 0)
    }
    
    func test_userUpdatesWithChangesInFirestoreHelper() {
        let given = Drinks(beers: 2, shots: 2)
        let received = Drinks(beers: 4, shots: 4)
        let outstanding = Drinks(beers: 6, shots: 6)
        
        sut.bindUserToListener()
        mock.currentUser = CurrentUser(
            uid: "someOtherUID",
            email: "email",
            firstName: "firstName",
            lastName: "lastName",
            userName: "userName",
            bio: "bio",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: Drinks(beers: 0, shots: 0),
            drinksReceived: Drinks(beers: 0, shots: 0),
            drinksOutstanding: Drinks(beers: 0, shots: 0),
            recentFriends: [String]()
        )
        mock.currentUser = CurrentUser(
            uid: "someOtherUID",
            email: "email",
            firstName: "firstName",
            lastName: "lastName",
            userName: "userName",
            bio: "bio",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: given,
            drinksReceived: received,
            drinksOutstanding: outstanding,
            recentFriends: [String]()
        )
        
        
        XCTAssertEqual(userDataChangeClosureCalls, 3)
        XCTAssertEqual(sut.user.drinksGiven, given)
        XCTAssertEqual(sut.user.drinksReceived, received)
        XCTAssertEqual(sut.user.drinksOutstanding, outstanding)
        
    }
    
    func test_initFetchPastBets() {
        sut.initFetchPastBets()
        XCTAssertEqual(mock.initPastBetFetches, 1)
        XCTAssertEqual(sut.pastBetCellVMs.count, 3)
        XCTAssertEqual(cellVMUpdateClosureCalls, 1)
        
        for i in 0..<sut.pastBetCellVMs.count {
            let vm = sut.pastBetCellVMs[i]
            XCTAssertEqual(vm.bet.betID, "closedBet\(i)")
        }
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_loadAdditionalPastBets() {
        sut.initFetchPastBets()
        sut.loadAdditionalPastBets()
        XCTAssertEqual(sut.pastBetCellVMs.count, 6)
        XCTAssertEqual(cellVMUpdateClosureCalls, 2)
        
        for i in 0..<sut.pastBetCellVMs.count {
            let vm = sut.pastBetCellVMs[i]
            XCTAssertEqual(vm.bet.betID, "closedBet\(i)")
        }
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_getVMsForPastTable() {
        sut.initFetchPastBets()
        let vms = sut.getCellVMsForTable()
        XCTAssertEqual(vms.count, 3)
        
        for i in 0..<vms.count {
            XCTAssertEqual(vms[i].bet.betID, "closedBet\(i)")
        }
    }
    
    func test_getVMsAtIndexPath() {
        sut.initFetchPastBets()
        sut.loadAdditionalPastBets()
        
        for i in 0..<sut.pastBetCellVMs.count {
            let indexPath = IndexPath(row: i, section: 0)
            let vm = sut.getCellVM(at: indexPath)
            XCTAssertEqual(vm.bet.betID, "closedBet\(i)")
        }

    }
    
    func test_getDrinkString() {
        sut.bindUserToListener()
        let given = Drinks(beers: 2, shots: 2)
        let received = Drinks(beers: 4, shots: 4)
        let outstanding = Drinks(beers: 6, shots: 6)
        mock.currentUser = CurrentUser(
            uid: "uid",
            email: "email",
            firstName: "firstName",
            lastName: "lastName",
            userName: "userName",
            bio: "bio",
            numBets: 0,
            numFriends: 0,
            betsWon: 0,
            betsLost: 0,
            drinksGiven: given,
            drinksReceived: received,
            drinksOutstanding: outstanding,
            recentFriends: [String]()
        )
        
        let expectedValues: [String] = [
            "2 🍺 2 🥃",
            "4 🍺 4 🥃",
            "6 🍺 6 🥃",
        ]
        
        for i in 0..<DrinkStatType.allCases.count {
            XCTAssertEqual(sut.getDrinksString(forStat: DrinkStatType.allCases[i]), expectedValues[i])
        }
    }
    
    func test_logOut() {
        sut.logOut(completion: nil)
        
        XCTAssertNil(mock.currentUser)
        XCTAssertTrue(mock.friends.isEmpty)
        XCTAssertTrue(mock.allUsers.isEmpty)
        XCTAssertTrue(mock.involvedBets.isEmpty)
        XCTAssertFalse(mock.isUserStoredFromDB)
        XCTAssertEqual(mock.logOuts, 1)
        XCTAssertEqual(mock.betDetailListeners, 0)
        
        // Below values expected to be 0 as these listeners are created in other VMs
        XCTAssertEqual(mock.currentUserListeners, -1)
        XCTAssertEqual(mock.userInvolvedBetsListeners, -1)
        XCTAssertEqual(mock.friendListeners, -1)
        XCTAssertEqual(mock.allUserListeners, -1)
        XCTAssertEqual(mock.friendOutstandingBetListeners, -1)
        XCTAssertEqual(mock.friendActiveBetListeners, -1)
        XCTAssertEqual(mock.friendDetailListeners, -1)
    }

}
