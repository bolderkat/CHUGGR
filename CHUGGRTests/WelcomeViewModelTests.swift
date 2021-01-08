//
//  WelcomeViewModelTests.swift
//  CHUGGRTests
//
//  Created by Daniel Luo on 1/8/21.
//

import XCTest
@testable import CHUGGR

class WelcomeViewModelTests: XCTestCase {

    private var sut: WelcomeViewModel!
    private var mock: MockFirestoreHelper!
    
    override func setUp() {
        super.setUp()
        mock = MockFirestoreHelper()
        sut = WelcomeViewModel(firestoreHelper: mock)
    }
    
    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }
    
    func test_getCurrentUserDetails() {
        var docNotFound = false
        var didUserReadFail = false
        mock.currentUser = nil
        
        sut.onUserDocNotFound = { docNotFound = true }
        sut.onUserReadFail = { didUserReadFail = true }
        
        sut.getCurrentUserDetails(with: "uid")
        
        XCTAssertNotNil(mock.currentUser)
        XCTAssertFalse(docNotFound)
        XCTAssertFalse(didUserReadFail)
        XCTAssertTrue(mock.isUserStoredFromDB)
        XCTAssertEqual(mock.currentUserListeners, 1)
    }
    
    func test_getNonexistentUser() {
        var docNotFound = false
        var didUserReadFail = false
        mock.currentUser = nil
        
        sut.onUserDocNotFound = { docNotFound = true }
        sut.onUserReadFail = { didUserReadFail = true }
        
        sut.getCurrentUserDetails(with: "nonexistentUser")
        
        XCTAssertNil(mock.currentUser)
        XCTAssertTrue(docNotFound)
        XCTAssertFalse(didUserReadFail)
        XCTAssertFalse(mock.isUserStoredFromDB)
        XCTAssertEqual(mock.currentUserListeners, 0)
    }
    
    func test_userReadFail() {
        var docNotFound = false
        var didUserReadFail = false
        mock.currentUser = nil
        
        sut.onUserDocNotFound = { docNotFound = true }
        sut.onUserReadFail = { didUserReadFail = true }
        
        sut.getCurrentUserDetails(with: "failedRead")
        
        XCTAssertNil(mock.currentUser)
        XCTAssertFalse(docNotFound)
        XCTAssertTrue(didUserReadFail)
        XCTAssertFalse(mock.isUserStoredFromDB)
        XCTAssertEqual(mock.currentUserListeners, 0)
    }

}
