//
//  AddFriendViewModelTests.swift
//  CHUGGRTests
//
//  Created by Daniel Luo on 1/12/21.
//

import XCTest
@testable import CHUGGR

class AddFriendViewModelTests: XCTestCase {

    var sut: AddFriendViewModel!
    var mock: MockFirestoreHelper!
    var friendUpdateClosureCalls = 0
    
    override func setUp() {
        super.setUp()
        mock = MockFirestoreHelper()
        sut = AddFriendViewModel(firestoreHelper: mock)
        sut.initSetUpAllUserListener()
    }
    
    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }
    
    func test_setUpAllUserListener() {
        XCTAssertEqual(mock.allUserListeners, 1)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_cellVMsCorrectlyPopulatedAfterFetch() {
        let usersNotYetFollowed = TestingData.users.dropLast(2)
        XCTAssertEqual(sut.allUserVMs.count, usersNotYetFollowed.count)
        
        for i in 0..<sut.allUserVMs.count {
            XCTAssertEqual(sut.allUserVMs[i].uid, usersNotYetFollowed[i].uid)
        }
    }
    
    func test_provideCellVMsWithFirstNameQuery() {
        let vms = sut.provideCellVMs(forString: "alex")
        
        XCTAssertEqual(vms.count, 2)
        XCTAssertEqual(vms[0].firstName, "Alex")
        XCTAssertEqual(vms[1].firstName, "Alex")
        XCTAssertEqual(vms[0].userName, "alexSmith94")
        XCTAssertEqual(vms[1].userName, "ac2020")
    }
    
    func test_provideCellVMsWithFirstNameLastInitialUppercaseQuery() {
        let vms = sut.provideCellVMs(forString: "ALEX C")
        
        XCTAssertEqual(vms.count, 1)
        XCTAssertEqual(vms.first!.firstName, "Alex")
        XCTAssertTrue(vms.first!.userName == "ac2020")
    }
    func test_provideCellVMsWithFirstNameLastInitialLowercaseQuery() {
        let vms = sut.provideCellVMs(forString: "russell w")
        XCTAssertEqual(vms.count, 2)
        XCTAssertEqual(vms[0].firstName, "Russell")
        XCTAssertEqual(vms[1].firstName, "Russell")
        XCTAssertEqual(vms[0].userName, "dangerussWilson")
        XCTAssertEqual(vms[1].userName, "recoveringbruin44")
        
    }
    
    func test_provideCellVMsWithLastNameQuery() {
        let vms = sut.provideCellVMs(forString: "curry")
        
        XCTAssertEqual(vms.count, 2)
        XCTAssertEqual(vms[0].firstName, "Wardell Stephen")
        XCTAssertEqual(vms[1].firstName, "Damion")
    }
    
    func test_provideCellVMsWithUserNameQuery() {
        let vms = sut.provideCellVMs(forString: "mr")
        
        XCTAssertEqual(vms.count, 2)
        XCTAssertEqual(vms[0].userName, "MrPMII")
        XCTAssertEqual(vms[1].userName, "MrWumbo")
    }
    
    func test_searchForAlreadyFollowedUsers() {
        let vms = sut.provideCellVMs(forString: "friend")
        XCTAssertEqual(vms.count, 0)
    }
    
    func test_searchForGibberish() {
        let vms = sut.provideCellVMs(forString: "2380-*GW_(*-fj3iowh")
        XCTAssertEqual(vms.count, 0)
    }
    
    func test_provideCellVMsAfterClearingSearch() {
        let usersNotYetFollowed = TestingData.users.dropLast(2)
        let _ = sut.provideCellVMs(forString: "2380-*GW_(*-fj3iowh")
        let vms = sut.provideCellVMs(forString: "")
        XCTAssertEqual(vms.count, usersNotYetFollowed.count)
        
        for i in 0..<vms.count {
            XCTAssertEqual(vms[i].uid, usersNotYetFollowed[i].uid)
        }
    }
    
    func test_provideCellVMsWithLetterAQuery() {
        let vms = sut.provideCellVMs(forString: "a")
        
        let userArray = mock.allUsers.dropLast(3)
        XCTAssertEqual(vms.count, userArray.count)
        
        for i in 0..<userArray.count {
            XCTAssertEqual(vms[i].uid, userArray[i].uid)
        }
    }
    
    func test_provideSelectedFriend() {
        let _ = sut.provideCellVMs(forString: "a")
        let userArray = mock.allUsers.dropLast(3)
        
        for i in 0..<userArray.count {
            let indexPath = IndexPath(row: i, section: 0)
            let selectedFriend = sut.provideSelectedFriend(at: indexPath)
            XCTAssertEqual(selectedFriend.uid, userArray[i].uid)
        }
    }
    
    func test_getFreshData() {
        var friendFetchClosureCalls = 0
        var fetchedFriend: FullFriend?
        sut.onFriendFetch = { friend in
            fetchedFriend = friend
            friendFetchClosureCalls += 1
        }
        
        let friend = TestingData.users[0]
        
        sut.getFreshData(for: friend)
        mock.friendCompletion(friend)
        XCTAssertEqual(mock.friendFetches, 1)
        XCTAssertEqual(friendFetchClosureCalls, 1)
        XCTAssertEqual(fetchedFriend!.uid, friend.uid)
    }
}

    
    
    

