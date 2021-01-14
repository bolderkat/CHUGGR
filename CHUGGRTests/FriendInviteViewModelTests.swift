//
//  FriendInviteViewModelTests.swift
//  CHUGGRTests
//
//  Created by Daniel Luo on 1/13/21.
//

import XCTest
@testable import CHUGGR

class FriendInviteViewModelTests: XCTestCase {

    var sut: FriendInviteViewModel!
    var mock: MockFirestoreHelper!
    var updateCellVMClosureCalls = 0
    var changeSelectedFriendClosureCalls = 0
    
    
    override func setUp() {
        super.setUp()
        mock = MockFirestoreHelper()
        sut = FriendInviteViewModel(firestoreHelper: mock)
        updateCellVMClosureCalls = 0
        changeSelectedFriendClosureCalls = 0
        
        sut.didUpdateCellVMs = { [weak self] _ in
            self?.updateCellVMClosureCalls += 1
        }
        
        sut.didChangeSelectedFriends = { [weak self] in
            self?.changeSelectedFriendClosureCalls += 1
        }
    }
    
    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }
    
    func test_fetchFriendsAndCreateCellVMs() {
        sut.fetchFriends()
        XCTAssertEqual(updateCellVMClosureCalls, 2)
        XCTAssertEqual(mock.friendListeners, 1)
        XCTAssertEqual(sut.cellVMs.count, mock.friends.count)
    }
    
    func test_searchWithEmptyField() {
        sut.fetchFriends()
        let vms = sut.provideCellVMs(forString: "")
        XCTAssertEqual(vms.count, mock.friends.count)
        for i in 0..<vms.count {
            XCTAssertEqual(vms[i].uid, mock.friends[i].uid)
        }
    }
    
    func test_searchForNonexistentUser() {
        sut.fetchFriends()
        let vms = sut.provideCellVMs(forString: "Z1")
        XCTAssertTrue(vms.isEmpty)
    }
    
    func test_searchForGibberish() {
        sut.fetchFriends()
        let vms = sut.provideCellVMs(forString: "hgpo298edlidsjfgpq398ahz;['")
        XCTAssertTrue(vms.isEmpty)
    }
    
    func test_searchForFirstName() {
        let queries = ["A", "B", "C", "D", "E", "F", "G", "H"]
        sut.fetchFriends()
        for query in queries {
            let vms = sut.provideCellVMs(forString: query)
            XCTAssertEqual(vms.count, 1)
            XCTAssertEqual(vms[0].firstName, query)
        }
    }
    
    func test_searchForLastName() {
        let queries = ["1", "2", "3", "4", "5", "6", "7", "8"]
        sut.fetchFriends()
        for query in queries {
            let vms = sut.provideCellVMs(forString: query)
            XCTAssertEqual(vms.count, 1)
            XCTAssertEqual(vms[0].lastName, query)
        }
    }
    
    func test_searchForFullNameWithSpace() {
        let queries = ["A 1", "B 2", "C 3", "D 4", "E 5", "F 6", "G 7", "H 8"]
        sut.fetchFriends()
        for query in queries {
            let vms = sut.provideCellVMs(forString: query)
            XCTAssertEqual(vms.count, 1)
            XCTAssertEqual(vms[0].fullName, query)
        }
    }
    
    func test_searchForFullNameWithoutSpace() {
        let queries = ["A1", "B2", "C3", "D4", "E5", "F6", "G7", "H8"]
        sut.fetchFriends()
        for query in queries {
            let vms = sut.provideCellVMs(forString: query)
            XCTAssertTrue(vms.isEmpty)
        }
    }
    
    func test_searchForUsername() {
        let queries = ["ZZ", "YY", "XX", "WW", "VV", "UU", "TT", "SS"]
        sut.fetchFriends()
        for query in queries {
            let vms = sut.provideCellVMs(forString: query)
            XCTAssertEqual(vms.count, 1)
            XCTAssertEqual(vms[0].userName, query)
        }
    }
    
    func test_lowercaseSearch() {
        let queries = ["zz", "yy", "xx", "ww", "vv", "uu", "tt", "ss"]
        sut.fetchFriends()
        for query in queries {
            let vms = sut.provideCellVMs(forString: query)
            XCTAssertEqual(vms.count, 1)
            XCTAssertEqual(vms[0].userName, query.uppercased())
        }
    }
    
    func test_selectAllUsers() {
        sut.fetchFriends()
        
        for i in 0..<sut.cellVMs.count {
            let indexPath = IndexPath(row: i, section: 0)
            sut.selectUser(at: indexPath)
            
            XCTAssertTrue(sut.cellVMs[i].isChecked)
            XCTAssertEqual(sut.selectedFriends.count, i + 1)
        }
        
        // One closure call for each select action + 2 from fetchFriends
        XCTAssertEqual(updateCellVMClosureCalls, sut.cellVMs.count + 2)
    }
    
    func test_selectAllThenDeselectSomeUsers() {
        sut.fetchFriends()
        
        for i in 0..<sut.cellVMs.count {
            let indexPath = IndexPath(row: i, section: 0)
            sut.selectUser(at: indexPath)
        }
        let deselectIndexes = [2, 4, 6]
        for index in deselectIndexes {
            let indexPath = IndexPath(row: index, section: 0)
            sut.selectUser(at: indexPath)
        }
        
        XCTAssertEqual(sut.selectedFriends.count, sut.cellVMs.count - deselectIndexes.count)
        XCTAssertFalse(sut.selectedFriends.contains(where: { $0.uid == "friend2" } ))
        XCTAssertFalse(sut.selectedFriends.contains(where: { $0.uid == "friend4" } ))
        XCTAssertFalse(sut.selectedFriends.contains(where: { $0.uid == "friend6" } ))
        XCTAssertEqual(updateCellVMClosureCalls, sut.cellVMs.count + deselectIndexes.count + 2)
    }
    
    func test_selectUserWithSearchQueryPresent() {
        sut.fetchFriends()
        let _ = sut.provideCellVMs(forString: "C")
        let indexPath = IndexPath(row: 0, section: 0)
        
        sut.selectUser(at: indexPath)
        
        XCTAssertTrue(sut.selectedFriends.contains(where: { $0.uid == "friend2" }))
    }
    
    func test_deselectUserWithSearchQueryPresent() {
        sut.fetchFriends()
        let _ = sut.provideCellVMs(forString: "C")
        let indexPath = IndexPath(row: 0, section: 0)
        
        sut.selectUser(at: indexPath)
        sut.selectUser(at: indexPath)
        
        XCTAssertFalse(sut.selectedFriends.contains(where: { $0.uid == "friend2" }))
    }

    func test_createCellVMsMarksCellAsCheckedIfFriendSelected() {
        sut.fetchFriends()
        
        for i in 0..<sut.cellVMs.count {
            let indexPath = IndexPath(row: i, section: 0)
            sut.selectUser(at: indexPath)
        }
        
        sut.createCellVMs()
        
        sut.cellVMs.forEach { (cell) in
            XCTAssertTrue(cell.isChecked)
        }
    }
    
    func test_getRecipientNamesIfNoneSelected() {
        sut.fetchFriends()
        XCTAssertEqual(sut.getRecipientNames(), "")
    }
    
    func test_getRecipientNamesIfOneSelected() {
        sut.fetchFriends()
        
        for i in 0..<sut.cellVMs.count {
            let indexPath = IndexPath(row: i, section: 0)
            sut.selectUser(at: indexPath)
            let expectedValue = "\(TestingData.friendSnippets[i].firstName) \(TestingData.friendSnippets[i].lastName)"
            
            XCTAssertEqual(sut.getRecipientNames(), expectedValue)
            
            sut.selectUser(at: indexPath)
        }
    }
    
    func test_getRecipientNamesIfSomeSelectedAndDeselected() {
        sut.fetchFriends()
        let selectedIndexes = [1, 2, 3, 4, 5, 6]
        let deselectedIndexes = [1, 3, 5]
        let expectedNames = [
            "\(TestingData.friendSnippets[2].firstName) \(TestingData.friendSnippets[2].lastName)",
            "\(TestingData.friendSnippets[4].firstName) \(TestingData.friendSnippets[4].lastName)",
            "\(TestingData.friendSnippets[6].firstName) \(TestingData.friendSnippets[6].lastName)"
        ]
        let expectedOutput = expectedNames.joined(separator: ", ")
        
        for index in selectedIndexes {
            let indexPath = IndexPath(row: index, section: 0)
            sut.selectUser(at: indexPath)
        }
        for index in deselectedIndexes {
            let indexPath = IndexPath(row: index, section: 0)
            sut.selectUser(at: indexPath)
        }
        
        XCTAssertEqual(sut.selectedFriends.count, selectedIndexes.count - deselectedIndexes.count)
        XCTAssertEqual(sut.getRecipientNames(), expectedOutput)
        
    }
    
    func test_getRecipientNamesIfAllSelected() {
        sut.fetchFriends()
        let expectedNames = TestingData.friendSnippets.map {
            "\($0.firstName) \($0.lastName)"
        }
        let expectedOutput = expectedNames.joined(separator: ", ")
        for i in 0..<sut.cellVMs.count {
            let indexPath = IndexPath(row: i, section: 0)
            sut.selectUser(at: indexPath)
        }
        
        XCTAssertEqual(sut.getRecipientNames(), expectedOutput)
    }

}
