//
//  FriendsViewModelTests.swift
//  CHUGGRTests
//
//  Created by Daniel Luo on 1/12/21.
//

import XCTest
@testable import CHUGGR

class FriendsViewModelTests: XCTestCase {

    var sut: FriendsViewModel!
    var mock: MockFirestoreHelper!
    var friendUpdateClosureCalls = 0
    
    override func setUp() {
        super.setUp()
        mock = MockFirestoreHelper()
        sut = FriendsViewModel(firestoreHelper: mock)
        friendUpdateClosureCalls = 0
        sut.didUpdateFriendCellVMs = { [weak self] in
            self?.friendUpdateClosureCalls += 1
        }
        
    }
    
    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }
    
    func test_fetchFriends() {
        sut.fetchFriends()
        XCTAssertEqual(friendUpdateClosureCalls, 2)
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
    
    func test_getFriendUIDWithEmptySearchBar() {
        sut.fetchFriends()
        for i in 0..<sut.cellVMs.count {
            let indexPath = IndexPath(row: i, section: 0)
            let uid = sut.getFriendUID(at: indexPath)
            XCTAssertEqual(uid, mock.friends[i].uid)
        }
    }
    
    func test_getFriendUIDWithSearchQuery() {
        sut.fetchFriends()
        let _ = sut.provideCellVMs(forString: "A")
        let indexPath = IndexPath(row: 0, section: 0)
        let uid = sut.getFriendUID(at: indexPath)
        XCTAssertEqual(uid, "friend0")
    }
    
    func test_getFriend() {
        var friendLoads = 0
        var loadedFriend: FullFriend?
        sut.onFriendLoad = { friend in
            loadedFriend = friend
            friendLoads += 1
        }
        for friend in TestingData.friends {
            sut.getFriend(withUID: friend.uid)
            XCTAssertEqual(friend.uid, loadedFriend!.uid)
        }
        XCTAssertEqual(mock.friendFetches, TestingData.friends.count)
        XCTAssertEqual(friendLoads, TestingData.friends.count)
    }
    
    func test_getFriendReturnsIfNoClosure() {
        sut.getFriend(withUID: "friend0")
        XCTAssertEqual(mock.friendFetches, 0)
    }

}
