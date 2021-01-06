//
//  UserDetailEntryViewModelTests.swift
//  CHUGGRTests
//
//  Created by Daniel Luo on 1/5/21.
//

import XCTest
@testable import CHUGGR

class UserDetailEntryViewModelTests: XCTestCase {
    
    private var sut: UserDetailEntryViewModel!
    private var mock: MockFirestoreHelper!
    
    override func setUp() {
        super.setUp()
        mock = MockFirestoreHelper()
        sut = UserDetailEntryViewModel(firestoreHelper: mock)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mock = nil
        super.tearDown()
    }
    
    func test_cellVMsCreatedForAllUserEntryRowTypes() {
        // When creating cell VMs
        sut.createCellVMs()
        
        // Then assert that expected number and types of rows exist
        XCTAssertEqual(sut.cellViewModels.count, UserEntryRowType.allCases.count)
        
        // Get raw values of each case
        let caseTitles = UserEntryRowType.allCases.map { $0.rawValue }
        for i in 0..<caseTitles.count {
            XCTAssertEqual(sut.cellViewModels[i].title, caseTitles[i])
        }
    }
    
    func test_tableViewReloadsOnCellVMUpdate() {
        // Given this closure
        var closureCalls = 0
        sut.reloadTableViewClosure = { closureCalls += 1 }
        
        // When creating cell VMs random number of times
        let randomNumber = Int.random(in: 1...10)
        for _ in 0..<randomNumber {
            sut.createCellVMs()
        }
        
        // Then closure should be called same number of times the cell VMs were created
        XCTAssertEqual(closureCalls, randomNumber)
        
    }
    
    func test_getCellViewModelReturnsCorrectCell() {
        sut.createCellVMs()
        
        for i in 0..<sut.cellViewModels.count {
            let indexPath = IndexPath(row: i, section: 0)
            let cellVM = sut.getCellViewModel(at: indexPath)
            XCTAssertEqual(sut.cellViewModels[i], cellVM)
        }
    }
    
    func test_inputHandlingFromCells() {
        
        // When handling input (from each row)
        for row in UserEntryRowType.allCases {
            sut.handle(text: row.rawValue, for: row)
        }
        
        // Then
        XCTAssertEqual(sut.firstNameInput, UserEntryRowType.firstName.rawValue)
        XCTAssertEqual(sut.lastNameInput, UserEntryRowType.lastName.rawValue)
        XCTAssertEqual(sut.userNameInput, UserEntryRowType.userName.rawValue)
        XCTAssertEqual(sut.bioInput, UserEntryRowType.bio.rawValue)
    }
    
    func test_inputValidation() {
        for row in UserEntryRowType.allCases {
            // Before all fields are filled
            XCTAssertFalse(sut.isInputComplete)
            sut.handle(text: row.rawValue, for: row)
        }
        
        // After all fields are filled
        XCTAssert(sut.isInputComplete)
        
    }
    
    func test_inputValidationAfterUserClearsAField() {
        for row in UserEntryRowType.allCases {
            sut.handle(text: row.rawValue, for: row)
        }
        
        XCTAssert(sut.isInputComplete)
        
        // Test clearing and then re-filling each field
        for row in UserEntryRowType.allCases {
            sut.handle(text: "", for: row)
            XCTAssertFalse(sut.isInputComplete)
            sut.handle(text: "asdf", for: row)
            XCTAssert(sut.isInputComplete)
        }
        
    }
    
    func test_ButtonUpdateClosureCalledWithUserInput() {
        // Action counter should increment every time user clears/populates an input field.
        // The button update closure should be called during the same event.
        var actionCounter = 0
        var closureCalls = 0
        sut.updateButtonStatus = { closureCalls += 1 }
        
        for row in UserEntryRowType.allCases {
            sut.handle(text: row.rawValue, for: row)
            actionCounter += 1
        }
        
        for row in UserEntryRowType.allCases {
            sut.handle(text: "", for: row)
            actionCounter += 1
            sut.handle(text: "asdf", for: row)
            actionCounter += 1
        }
        
        XCTAssertEqual(actionCounter, closureCalls)
        
    }
    
    
    func test_submitUser() {
        sut.ifUserNameTaken = {}
        sut.submitInput()
        
        XCTAssert(mock.isUserCreated)
        XCTAssert(mock.isUserWrittenToDB)
        XCTAssert(mock.isUserStoredFromDB)
        XCTAssertEqual(mock.currentUserListeners, 1)
    }
    
    
}
