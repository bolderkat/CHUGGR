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
    
    override func tearDown() {
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
    
    func test_userInputValidation() {
        // Action counter should increment every time user clears/populates an input field.
        // The button update closure should be called during the same event.
        var trueActionCounter = 0
        var falseActionCounter = 0
        var trueClosureCalls = 0
        var falseClosureCalls = 0
        sut.didValidateInput = { isInputValid in
            if isInputValid {
                trueClosureCalls += 1
            } else {
                falseClosureCalls += 1
            }
        }
        
        let rowTypes = UserEntryRowType.allCases
        for i in 0..<UserEntryRowType.allCases.count {
            
            if i < UserEntryRowType.allCases.count - 1 {
                // Every row up to but not including the last case triggers a false closure call
                falseActionCounter += 1
            }
            
            sut.handle(text: rowTypes[i].rawValue, for: rowTypes[i])
        }
        
        // All rows are now full, so we should have a true closure call
        trueActionCounter += 1
        
        for row in UserEntryRowType.allCases {
            sut.handle(text: "", for: row)
            falseActionCounter += 1
            sut.handle(text: "asdf", for: row)
            trueActionCounter += 1
        }
        
        XCTAssertEqual(falseActionCounter, falseClosureCalls)
        XCTAssertEqual(trueActionCounter, trueClosureCalls)
    }
    
    
    func test_submitUserSuccess() {
        var isUserNameTaken = false
        sut.ifUserNameTaken = { isUserNameTaken = true }
        sut.submitInput()
        
        XCTAssertFalse(isUserNameTaken)
        XCTAssertTrue(mock.isUserCreated)
        XCTAssertTrue(mock.isUserWrittenToDB)
        XCTAssertTrue(mock.isUserStoredFromDB)
        XCTAssertEqual(mock.currentUserListeners, 1)
    }
    
    func test_submitUserFailWithUserNameTaken() {
        var isUserNameTaken = false
        sut.ifUserNameTaken = { isUserNameTaken = true }
        sut.handle(text: "takenUserName", for: .userName)
        sut.submitInput()
        
        XCTAssertTrue(isUserNameTaken)
        XCTAssertFalse(mock.isUserCreated)
        XCTAssertFalse(mock.isUserWrittenToDB)
        XCTAssertFalse(mock.isUserStoredFromDB)
        XCTAssertEqual(mock.currentUserListeners, 0)
    }
    
    
}
