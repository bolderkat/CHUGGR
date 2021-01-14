//
//  FriendDetailViewModelTests.swift
//  CHUGGRTests
//
//  Created by Daniel Luo on 1/13/21.
//

import XCTest
@testable import CHUGGR

class FriendDetailViewModelTests: XCTestCase {

    var sut: FriendDetailViewModel!
    var mock: MockFirestoreHelper!
    var friend = TestingData.friends[0]
    var friendUpdateClosureCalls = 0
    var friendStatusChangeClosureCalls = 0
    var betUpdateClosureCalls = 0
    
    override func setUp() {
        super.setUp()
        mock = MockFirestoreHelper()
        friend = TestingData.friends[0]
        friendUpdateClosureCalls = 0
        friendStatusChangeClosureCalls = 0
        betUpdateClosureCalls = 0
        sut = FriendDetailViewModel(firestoreHelper: mock, friend: friend)
        
        sut.didUpdateFriend = { [weak self] in
            self?.friendUpdateClosureCalls += 1
        }
        
        sut.didReceiveFriendStatusChangeAction = { [weak self] in
            self?.friendStatusChangeClosureCalls += 1
        }
        
        sut.onBetUpdateOrTableChange = { [weak self] in
            self?.betUpdateClosureCalls += 1
        }
    }
    
    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }
    
    func test_setFriendListenerForFriend() {
        sut.setFriendListener()
        // Update via listener with a different friend
        mock.friendCompletion(TestingData.friends[1])
        
        XCTAssertEqual(mock.friendDetailListeners, 1)
        XCTAssertEqual(friendUpdateClosureCalls, 1)
        XCTAssertEqual(sut.friend.uid, TestingData.friends[1].uid)
        XCTAssertTrue(sut.isAlreadyFriends)
        XCTAssertTrue(sut.isRemoveButtonActive)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_setFriendListenerForNonFriend() {
        sut.setFriendListener()
        mock.friendCompletion(TestingData.users[0])
        
        XCTAssertEqual(mock.friendDetailListeners, 1)
        XCTAssertEqual(friendUpdateClosureCalls, 1)
        XCTAssertEqual(sut.friend.uid, TestingData.users[0].uid)
        XCTAssertFalse(sut.isAlreadyFriends)
        XCTAssertFalse(sut.isRemoveButtonActive)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_addActiveBetListeners() {
        sut.addActiveBetListeners()
        XCTAssertEqual(mock.friendActiveBetListeners, 1)
        XCTAssertEqual(mock.friendOutstandingBetListeners, 1)
        
        XCTAssertEqual(sut.outstandingBetCellVMs.count, 3)
        XCTAssertEqual(sut.activeBets.count, 4)
        XCTAssertEqual(mock.friendActiveBetListeners, 1)
        XCTAssertEqual(betUpdateClosureCalls, 2)
        
        for i in 0..<sut.outstandingBetCellVMs.count {
            let vm = sut.outstandingBetCellVMs[i]
            XCTAssertEqual(vm.bet.betID, "outstandingBet\(i)")
        }
        for i in 0..<sut.activeBetCellVMs.count {
            let vm = sut.activeBetCellVMs[i]
            XCTAssertEqual(vm.bet.betID, "openBet\(i)")
        }
    }
    
    func test_initFetchPastBets() {
        sut.initFetchPastBets()
        XCTAssertEqual(mock.initPastBetFetches, 1)
        XCTAssertEqual(sut.pastBetCellVMs.count, 3)
        XCTAssertEqual(betUpdateClosureCalls, 0)
        
        for i in 0..<sut.pastBetCellVMs.count {
            let vm = sut.pastBetCellVMs[i]
            XCTAssertEqual(vm.bet.betID, "closedBet\(i)")
        }
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_setTableSelectionToPastLoadsPastBets() {
        sut.selectedTable = .pastBets
        XCTAssertEqual(sut.pastBetCellVMs.count, 3)
        
        for i in 0..<sut.pastBetCellVMs.count {
            let vm = sut.pastBetCellVMs[i]
            XCTAssertEqual(vm.bet.betID, "closedBet\(i)")
        }
        XCTAssertEqual(betUpdateClosureCalls, 1)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_setTableSelectionToActiveTriggersClosure() {
        sut.selectedTable = .active
        XCTAssertEqual(betUpdateClosureCalls, 1)
    }
    
    
    func test_loadAdditionalPastBets() {
        sut.selectedTable = .pastBets
        sut.loadAdditionalPastBets()
        XCTAssertEqual(sut.pastBetCellVMs.count, 6)
        XCTAssertEqual(betUpdateClosureCalls, 2)
        
        for i in 0..<sut.pastBetCellVMs.count {
            let vm = sut.pastBetCellVMs[i]
            XCTAssertEqual(vm.bet.betID, "closedBet\(i)")
        }
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_cleanUpFirestore() {
        sut.setFriendListener()
        sut.addActiveBetListeners()
        XCTAssertEqual(mock.friendDetailListeners, 1)
        XCTAssertEqual(mock.friendActiveBetListeners, 1)
        
        sut.cleanUpFirestore()
        XCTAssertEqual(mock.friendDetailListeners, 0)
        XCTAssertEqual(mock.friendActiveBetListeners, 0)
    }
    
    func test_getVMsForActiveTable() {
        sut.addActiveBetListeners()
        XCTAssertEqual(sut.selectedTable, .active)
        let expectedValues = sut.outstandingBetCellVMs + sut.activeBetCellVMs
        let vms = sut.getCellVMsForTable()
        XCTAssertEqual(vms, expectedValues)
        XCTAssertEqual(vms.count, 7)
        
        for i in 0..<vms.count {
            XCTAssertEqual(vms[i].bet.betID, expectedValues[i].bet.betID)
        }
    }
    
    func test_getVMsForPastTable() {
        sut.selectedTable = .pastBets
        let vms = sut.getCellVMsForTable()
        XCTAssertEqual(vms.count, 3)
        
        for i in 0..<vms.count {
            XCTAssertEqual(vms[i].bet.betID, "closedBet\(i)")
        }
    }
    
    func test_getActiveCellVMs() {
        sut.addActiveBetListeners()
        let expectedBetIDs = [
            "outstandingBet0",
            "outstandingBet1",
            "outstandingBet2",
            "openBet0",
            "openBet1",
            "openBet2",
            "openBet3",
        ]
        
        for i in 0..<expectedBetIDs.count {
            let indexPath = IndexPath(row: i, section: 0)
            let vm = sut.getCellVM(at: indexPath)
            XCTAssertEqual(vm.bet.betID, expectedBetIDs[i])
        }
    }
    
    func test_getPastCellVMs() {
        sut.selectedTable = .pastBets
        sut.loadAdditionalPastBets()
        
        for i in 0..<sut.pastBetCellVMs.count {
            let indexPath = IndexPath(row: i, section: 0)
            let vm = sut.getCellVM(at: indexPath)
            XCTAssertEqual(vm.bet.betID, "closedBet\(i)")
        }
    }
    
    func test_getDrinkString() {
        let expectedValues: [String] = [
            "1 🍺 2 🥃",
            "3 🍺 4 🥃",
            "5 🍺 6 🥃",
        ]
        
        for i in 0..<DrinkStatType.allCases.count {
            XCTAssertEqual(sut.getDrinksString(forStat: DrinkStatType.allCases[i]), expectedValues[i])
        }
    }
    
    func test_checkTrueFriendStatus() {
        sut.checkFriendStatus()
        XCTAssertTrue(sut.isAlreadyFriends)
        XCTAssertTrue(sut.isRemoveButtonActive)
    }
    
    func test_checkFalseFriendStatus() {
        sut = FriendDetailViewModel(firestoreHelper: mock, friend: TestingData.users[0])
        sut.checkFriendStatus()
        XCTAssertFalse(sut.isAlreadyFriends)
        XCTAssertFalse(sut.isRemoveButtonActive)
    }
    
    func test_addFriend() {
        sut = FriendDetailViewModel(firestoreHelper: mock, friend: TestingData.users[0])
        let originalFriendCount = mock.friends.count
        sut.addFriend()
        
        XCTAssertEqual(mock.friendAdds, 1)
        XCTAssertEqual(mock.friends.count, originalFriendCount + 1)
        
        let addedFriend = mock.friends.last!
        XCTAssertEqual(addedFriend.uid, TestingData.users[0].uid)
        
        XCTAssertFalse(sut.isAlreadyFriends)
        XCTAssertFalse(sut.isRemoveButtonActive)
        mock.voidCompletion()
        XCTAssertTrue(sut.isAlreadyFriends)
        XCTAssertTrue(sut.isRemoveButtonActive)
    }
    
    func test_removeFriend() {
        let originalFriendCount = mock.friends.count
        sut.checkFriendStatus()
        XCTAssertTrue(sut.isRemoveButtonActive)
        sut.removeFriend()
        
        XCTAssertEqual(mock.friendRemoves, 1)
        XCTAssertEqual(mock.friends.count, originalFriendCount - 1)
        
        let snippetToCheck = FriendSnippet(fromFriend: sut.friend)
        XCTAssertFalse(mock.friends.contains(snippetToCheck))
        
        XCTAssertTrue(sut.isAlreadyFriends)
        mock.voidCompletion()
        XCTAssertFalse(sut.isAlreadyFriends)
        XCTAssertFalse(sut.isRemoveButtonActive)
    }
}
