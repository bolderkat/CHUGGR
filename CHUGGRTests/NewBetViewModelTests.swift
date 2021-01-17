//
//  NewBetViewModelTests.swift
//  CHUGGRTests
//
//  Created by Daniel Luo on 1/14/21.
//

import XCTest
@testable import CHUGGR

class NewBetViewModelTests: XCTestCase {

    var sut: NewBetViewModel!
    var mock: MockFirestoreHelper!
    var updateCellVMClosureCalls = 0
    var validateInputClosureCalls = 0
    var isInputValid = false
    
    override func setUp() {
        super.setUp()
        mock = MockFirestoreHelper()
        sut = NewBetViewModel(firestoreHelper: mock, invitedFriends: [])
        updateCellVMClosureCalls = 0
        validateInputClosureCalls = 0
        
        sut.didUpdateCellVMs = { [weak self] in
            self?.updateCellVMClosureCalls += 1
        }
        
        sut.didValidateInput = { [weak self] isInputValid in
            self?.validateInputClosureCalls += 1
            self?.isInputValid = isInputValid
        }
    }
    
    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }
    
    func test_getVCTItleForHouseBet() {
        XCTAssertEqual(sut.getVCTitle(), "House Bet")
    }
    
    func test_getVCTitleWithOneInvitee() {
        let friend = TestingData.friendSnippets[0]
        sut = NewBetViewModel(firestoreHelper: mock, invitedFriends: [friend])
        let expectedOutput = "\(friend.firstName) \(friend.lastName)"
        
        XCTAssertEqual(sut.getVCTitle(), expectedOutput)
    }
    
    func test_getVCTitleWithMulitpleInvitees() {
        sut = NewBetViewModel(firestoreHelper: mock, invitedFriends: TestingData.friendSnippets)
        let expectedOutput = "Bet with \(TestingData.friendSnippets.count) people"
        
        XCTAssertEqual(sut.getVCTitle(), expectedOutput)
    }
    
    func test_createCellVMsForSpreadBet() {
        sut.changeBetType(0)
        
        XCTAssertEqual(updateCellVMClosureCalls, 1)
        XCTAssertEqual(sut.cellViewModels.count, 4)
        XCTAssertEqual(sut.cellViewModels[0].title, "Stat")
        XCTAssertEqual(sut.cellViewModels[1].title, "Line")
        XCTAssertEqual(sut.cellViewModels[2].title, "Due date")
        XCTAssertEqual(sut.cellViewModels[3].title, "Stake")
    }
    
    func test_createCellVMsForSpreadBetAfterSwitchingTypes() {
        sut.changeBetType(1)
        sut.changeBetType(2)
        sut.changeBetType(0)
        
        XCTAssertEqual(updateCellVMClosureCalls, 3)
        XCTAssertEqual(sut.cellViewModels.count, 4)
        XCTAssertEqual(sut.cellViewModels[0].title, "Stat")
        XCTAssertEqual(sut.cellViewModels[1].title, "Line")
        XCTAssertEqual(sut.cellViewModels[2].title, "Due date")
        XCTAssertEqual(sut.cellViewModels[3].title, "Stake")
    }
    
    func test_createCellVMsForMoneylineBet() {
        sut.changeBetType(2)
        sut.changeBetType(0)
        sut.changeBetType(1)
        
        XCTAssertEqual(updateCellVMClosureCalls, 3)
        XCTAssertEqual(sut.cellViewModels.count, 4)
        XCTAssertEqual(sut.cellViewModels[0].title, "Team 1")
        XCTAssertEqual(sut.cellViewModels[1].title, "Team 2")
        XCTAssertEqual(sut.cellViewModels[2].title, "Due date")
        XCTAssertEqual(sut.cellViewModels[3].title, "Stake")
    }
    
    func test_createCellVMsForMoneylineBetAfterSwitchingTypes() {
        sut.changeBetType(1)
        
        XCTAssertEqual(updateCellVMClosureCalls, 1)
        XCTAssertEqual(sut.cellViewModels.count, 4)
        XCTAssertEqual(sut.cellViewModels[0].title, "Team 1")
        XCTAssertEqual(sut.cellViewModels[1].title, "Team 2")
        XCTAssertEqual(sut.cellViewModels[2].title, "Due date")
        XCTAssertEqual(sut.cellViewModels[3].title, "Stake")
    }
    
    
    func test_createCellVMsForEventBet() {
        sut.changeBetType(2)
        
        XCTAssertEqual(updateCellVMClosureCalls, 1)
        XCTAssertEqual(sut.cellViewModels.count, 3)
        XCTAssertEqual(sut.cellViewModels[0].title, "Event")
        XCTAssertEqual(sut.cellViewModels[1].title, "Due date")
        XCTAssertEqual(sut.cellViewModels[2].title, "Stake")
    }
    
    func test_createCellVMsForEventBetAfterSwitchingTypes() {
        sut.changeBetType(1)
        sut.changeBetType(0)
        sut.changeBetType(2)
        
        XCTAssertEqual(updateCellVMClosureCalls, 3)
        XCTAssertEqual(sut.cellViewModels.count, 3)
        XCTAssertEqual(sut.cellViewModels[0].title, "Event")
        XCTAssertEqual(sut.cellViewModels[1].title, "Due date")
        XCTAssertEqual(sut.cellViewModels[2].title, "Stake")
    }
    
    func test_changeBetTypeReturnsIfInvalidType() {
        sut.changeBetType(5235)
        XCTAssertEqual(updateCellVMClosureCalls, 0)
    }
    
    func test_getCellVMForSpreadBet() {
        sut.changeBetType(0)
        
        for i in 0..<sut.cellViewModels.count {
            let indexPath = IndexPath(row: i, section: 0)
            let vm = sut.getCellViewModel(at: indexPath)
            XCTAssertEqual(vm.title, sut.cellViewModels[i].title)
        }
    }
    
    func test_getCellVMForMoneylineBet() {
        sut.changeBetType(1)
        
        for i in 0..<sut.cellViewModels.count {
            let indexPath = IndexPath(row: i, section: 0)
            let vm = sut.getCellViewModel(at: indexPath)
            XCTAssertEqual(vm.title, sut.cellViewModels[i].title)
        }
    }
    
    func test_getCellVMForEventBet() {
        sut.changeBetType(2)
        
        for i in 0..<sut.cellViewModels.count {
            let indexPath = IndexPath(row: i, section: 0)
            let vm = sut.getCellViewModel(at: indexPath)
            XCTAssertEqual(vm.title, sut.cellViewModels[i].title)
        }
    }
    
    func test_clearInputStorage() {
        sut.titleInput = "blah"
        sut.lineInput = 2.5
        sut.team1Input = "blah"
        sut.team2Input = "blah"
        sut.dueDateInput = 10000
        sut.stakeInput = Drinks(beers: 1, shots: 1)
        
        sut.clearInputStorage()
        
        XCTAssertNil(sut.titleInput)
        XCTAssertNil(sut.lineInput)
        XCTAssertNil(sut.team1Input)
        XCTAssertNil(sut.team2Input)
        XCTAssertNil(sut.dueDateInput)
        XCTAssertNil(sut.stakeInput)
    }
    
    func test_changeSide() {
        let sideSelections = [0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1]
        
        for side in sideSelections {
            sut.changeSide(side)
            if side == 0 {
                XCTAssertEqual(sut.selectedSide, .one)
            } else {
                XCTAssertEqual(sut.selectedSide, .two)
            }
        }
    }
    
    func test_invalidChangeSide() {
        sut.changeSide(1)
        sut.changeSide(12389472389)
        XCTAssertEqual(sut.selectedSide, .two)
    }
    
    func test_handleStatInput() {
        let text = "blah blah"
        sut.handle(text: text, for: .stat)
        XCTAssertEqual(sut.titleInput, text)
        sut.handle(text: "", for: .stat)
        XCTAssertEqual(sut.titleInput, "")
        XCTAssertEqual(validateInputClosureCalls, 2)
    }
    
    func test_handleEventInput() {
        let text = "blah blah"
        sut.handle(text: text, for: .event)
        XCTAssertEqual(sut.titleInput, text)
        sut.handle(text: "", for: .event)
        XCTAssertEqual(sut.titleInput, "")
        XCTAssertEqual(validateInputClosureCalls, 2)
    }
    
    func test_handleLineInput() {
        let text = "8.5"
        sut.handle(text: text, for: .line)
        XCTAssertEqual(sut.lineInput, Double(text))
        sut.handle(text: "", for: .line)
        XCTAssertNil(sut.lineInput)
        XCTAssertEqual(validateInputClosureCalls, 2)
    }
    
    func test_handleLineInputCleaning() {
        let text = "042345."
        let expectedValue = 42345.0
        sut.handle(text: text, for: .line)
        XCTAssertEqual(sut.lineInput, expectedValue)
        XCTAssertEqual(validateInputClosureCalls, 1)
    }
    
    func test_RejectInvalidInput() {
        sut.handle(text: "-20", for: .line)
        XCTAssertNil(sut.lineInput)
        sut.handle(text: "235989eiopvfd", for: .line)
        XCTAssertNil(sut.lineInput)
        XCTAssertEqual(validateInputClosureCalls, 2)
    }
    
    func test_handleTeam1Input() {
        let text = "blah blah"
        sut.handle(text: text, for: .team1)
        XCTAssertEqual(sut.team1Input, text)
        sut.handle(text: "", for: .team1)
        XCTAssertEqual(sut.team1Input, "")
        XCTAssertEqual(validateInputClosureCalls, 2)
    }
    
    func test_handleTeam2Input() {
        let text = "blah blah"
        sut.handle(text: text, for: .team2)
        XCTAssertEqual(sut.team2Input, text)
        sut.handle(text: "", for: .team2)
        XCTAssertEqual(sut.team2Input, "")
        XCTAssertEqual(validateInputClosureCalls, 2)
    }
    
    func test_handleDateInput() {
        let timeInterval: TimeInterval = 12345678
        sut.handle(date: timeInterval)
        XCTAssertEqual(sut.dueDateInput, timeInterval)
        XCTAssertEqual(validateInputClosureCalls, 1)
    }
    
    func test_handleStakeInput() {
        let expectedValue = Drinks(beers: 3, shots: 5)
        sut.handle(beerStake: "3", shotStake: "5")
        XCTAssertEqual(sut.stakeInput, expectedValue)
        XCTAssertEqual(validateInputClosureCalls, 1)
    }
    
    func test_handleNilStakeInput() {
        let expectedValue = Drinks(beers: 0, shots: 0)
        sut.handle(beerStake: nil, shotStake: nil)
        XCTAssertEqual(sut.stakeInput, expectedValue)
        XCTAssertEqual(validateInputClosureCalls, 1)
    }
    
    func test_handleNonNumericStakeInput() {
        let expectedValue = Drinks(beers: 0, shots: 0)
        sut.handle(beerStake: "3oig", shotStake: "nil")
        XCTAssertEqual(sut.stakeInput, expectedValue)
        XCTAssertEqual(validateInputClosureCalls, 1)
    }
    
    func test_validateSpreadInput() {
        XCTAssertFalse(isInputValid)
        sut.handle(text: "title", for: .stat)
        XCTAssertFalse(isInputValid)
        sut.handle(text: "6.5", for: .line)
        XCTAssertFalse(isInputValid)
        sut.handle(date: Date.init().timeIntervalSince1970 + 100)
        XCTAssertFalse(isInputValid)
        sut.handle(beerStake: "1", shotStake: "1")
        XCTAssertEqual(validateInputClosureCalls, 4)
        XCTAssertTrue(isInputValid)
    }
    
    func test_validateMoneylineInput() {
        sut.changeBetType(1)
        XCTAssertFalse(isInputValid)
        sut.handle(text: "team1", for: .team1)
        XCTAssertFalse(isInputValid)
        sut.handle(text: "team2", for: .team2)
        XCTAssertFalse(isInputValid)
        sut.handle(date: Date.init().timeIntervalSince1970 + 100)
        XCTAssertFalse(isInputValid)
        sut.handle(beerStake: "1", shotStake: "1")
        XCTAssertEqual(validateInputClosureCalls, 5)
        XCTAssertTrue(isInputValid)
    }
    
    func test_validateEventInput() {
        sut.changeBetType(2)
        XCTAssertFalse(isInputValid)
        sut.handle(text: "title", for: .event)
        XCTAssertFalse(isInputValid)
        sut.handle(date: Date.init().timeIntervalSince1970 + 100)
        XCTAssertFalse(isInputValid)
        sut.handle(beerStake: "1", shotStake: "1")
        XCTAssertEqual(validateInputClosureCalls, 4)
        XCTAssertTrue(isInputValid)
    }
    
    func test_InputInvalidatesIfFieldCleared() {
        XCTAssertFalse(isInputValid)
        sut.handle(text: "title", for: .stat)
        XCTAssertFalse(isInputValid)
        sut.handle(text: "6.5", for: .line)
        XCTAssertFalse(isInputValid)
        sut.handle(date: Date.init().timeIntervalSince1970 + 100)
        XCTAssertFalse(isInputValid)
        sut.handle(beerStake: "1", shotStake: "1")
        XCTAssertTrue(isInputValid)
        sut.handle(text: "", for: .stat)
        XCTAssertFalse(isInputValid)
    }
    
    func test_createBetReturnsNilIfNoLoggedInUser() {
        mock.currentUser = nil
        XCTAssertNil(sut.createNewBet())
    }
    
    func test_createSpreadBet() {
        sut.handle(text: "title", for: .stat)
        sut.handle(text: "6.5", for: .line)
        sut.handle(date: Date.init().timeIntervalSince1970 + 100)
        sut.handle(beerStake: "1", shotStake: "1")
        XCTAssertEqual(sut.createNewBet(), "betID")
        XCTAssertEqual(mock.newBetWrites, 1)
        XCTAssertEqual(mock.newBet!.type, .spread)
        XCTAssertEqual(mock.newBet!.betID, "betID")
        XCTAssertEqual(mock.newBet!.title, "title")
        XCTAssertEqual(mock.newBet!.line, 6.5)
        XCTAssertLessThan(mock.newBet!.dueDate, Date.init().timeIntervalSince1970 + 100)
        XCTAssertEqual(mock.newBet!.stake, Drinks(beers: 1, shots: 1))
        XCTAssertNotNil(mock.newBet!.side1Users["uid"])
    }
    
    func test_createMoneylineBet() {
        sut.changeBetType(1)
        sut.handle(text: "team1", for: .team1)
        sut.handle(text: "team2", for: .team2)
        sut.handle(date: Date.init().timeIntervalSince1970 + 100)
        sut.handle(beerStake: "1", shotStake: "1")
        XCTAssertEqual(sut.createNewBet(), "betID")
        XCTAssertEqual(mock.newBetWrites, 1)
        XCTAssertEqual(mock.newBet!.type, .moneyline)
        XCTAssertEqual(mock.newBet!.betID, "betID")
        XCTAssertEqual(mock.newBet!.title, "team1 vs. team2")
        XCTAssertEqual(mock.newBet!.team1, "team1")
        XCTAssertEqual(mock.newBet!.team2, "team2")
        XCTAssertLessThan(mock.newBet!.dueDate, Date.init().timeIntervalSince1970 + 100)
        XCTAssertEqual(mock.newBet!.stake, Drinks(beers: 1, shots: 1))
        XCTAssertNotNil(mock.newBet!.side1Users["uid"])
    }
    
    func test_createEventBet() {
        sut.changeBetType(2)
        sut.handle(text: "title", for: .event)
        sut.handle(date: Date.init().timeIntervalSince1970 + 100)
        sut.handle(beerStake: "1", shotStake: "1")
        XCTAssertEqual(sut.createNewBet(), "betID")
        XCTAssertEqual(mock.newBetWrites, 1)
        XCTAssertEqual(mock.newBet!.betID, "betID")
        XCTAssertEqual(mock.newBet!.title, "title")
        XCTAssertLessThan(mock.newBet!.dueDate, Date.init().timeIntervalSince1970 + 100)
        XCTAssertEqual(mock.newBet!.stake, Drinks(beers: 1, shots: 1))
        XCTAssertNotNil(mock.newBet!.side1Users["uid"])
    }
    
    func test_createInvalidSpreadBet() {
        sut.handle(text: "title", for: .stat)
        sut.handle(text: "6.5", for: .line)
        sut.handle(date: Date.init().timeIntervalSince1970 + 100)
        XCTAssertNil(sut.createNewBet())
        XCTAssertEqual(mock.newBetWrites, 0)
    }
    
    func test_createInvalidMoneylineBet() {
        sut.changeBetType(1)
        sut.handle(text: "team2", for: .team2)
        sut.handle(date: Date.init().timeIntervalSince1970 + 100)
        sut.handle(beerStake: "1", shotStake: "1")
        XCTAssertNil(sut.createNewBet())
        XCTAssertEqual(mock.newBetWrites, 0)
    }
    
    func test_createInvalidEventBet() {
        sut.changeBetType(2)
        sut.handle(date: Date.init().timeIntervalSince1970 + 100)
        sut.handle(beerStake: "1", shotStake: "1")
        XCTAssertNil(sut.createNewBet())
        XCTAssertEqual(mock.newBetWrites, 0)
    }
    
    func test_createSide2Bet() {
        sut.changeSide(1)
        sut.handle(text: "title", for: .stat)
        sut.handle(text: "6.5", for: .line)
        sut.handle(date: Date.init().timeIntervalSince1970 + 100)
        sut.handle(beerStake: "1", shotStake: "1")
        XCTAssertEqual(sut.createNewBet(), "betID")
        XCTAssertEqual(mock.newBetWrites, 1)
        XCTAssertNotNil(mock.newBet!.side2Users["uid"])
    }
    
    func test_createBetWithFriends() {
        sut = NewBetViewModel(firestoreHelper: mock, invitedFriends: TestingData.friendSnippets)
        sut.handle(text: "title", for: .stat)
        sut.handle(text: "6.5", for: .line)
        sut.handle(date: Date.init().timeIntervalSince1970 + 100)
        sut.handle(beerStake: "1", shotStake: "1")
        XCTAssertEqual(sut.createNewBet(), "betID")
        XCTAssertEqual(mock.newBetWrites, 1)
        XCTAssertEqual(mock.newBet!.invitedUsers.count, TestingData.friendSnippets.count)
    }
    
    
}
