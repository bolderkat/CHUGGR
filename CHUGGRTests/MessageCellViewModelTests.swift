//
//  MessageCellViewModelTests.swift
//  CHUGGRTests
//
//  Created by Daniel Luo on 1/8/21.
//

import XCTest
@testable import CHUGGR
class MessageCellViewModelTests: XCTestCase {

    var sut: MessageCellViewModel!
    
    override func setUp() {
        super.setUp()
        let message = Message(uid: "uid", userName: "userName", body: "body", timestamp: 1610149619)
        
        sut = MessageCellViewModel(
            message: message,
            shouldHideSenderRow: false,
            currentUID: "uid"
        )
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_getTimeString() {
        XCTAssertEqual(sut.getTimeString(), "1/8/21, 3:46 pm")
    }

}
