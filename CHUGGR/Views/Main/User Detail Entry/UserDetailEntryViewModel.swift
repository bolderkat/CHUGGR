//
//  UserDetailEntryViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/10/20.
//

import Foundation
import Firebase
class UserDetailEntryViewModel {
    private let firestoreHelper: FirestoreHelper
    private(set) var cellViewModels = [UserDetailEntryCellViewModel]() {
        didSet {
            reloadTableViewClosure?()
        }
    }
    
    private(set) var isInputComplete = false {
        didSet {
            updateButtonStatus?() // enable/disable button based on user input
        }
    }
    
    var firstNameInput = ""
    var lastNameInput = ""
    var screenNameInput = ""
    var bioInput = ""
    
    var reloadTableViewClosure: (() -> ())?
    var updateButtonStatus: (() -> ())?
    var ifScreenNameTaken: (() -> ())?
    
    init(firestoreHelper: FirestoreHelper) {
        self.firestoreHelper = firestoreHelper
    }
    
    func createCellVMs() {
        let rowTypes = [
            UserEntryRowType.firstName,
            UserEntryRowType.lastName,
            UserEntryRowType.screenName,
            UserEntryRowType.bio
        ]
        
        // Create array of cell VMs based on row types above
        var vms = [UserDetailEntryCellViewModel]()
        for type in rowTypes {
            vms.append(UserDetailEntryCellViewModel(type: type))
        }
        cellViewModels = vms
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> UserDetailEntryCellViewModel {
        cellViewModels[indexPath.row]
    }
    
    // MARK:- Input processing from cells
    
    func handle(text: String, for rowType: UserEntryRowType) {
        // Store textfield input into variables based on row type
        switch rowType {
        case .firstName:
            firstNameInput = text
        case .lastName:
            lastNameInput = text
        case .screenName:
            screenNameInput = text
        case .bio:
            bioInput = text
        }
        validateInput()
    }
    
    func validateInput() {
        // Make sure all fields have input before marking input complete
        if !firstNameInput.isEmpty,
           !lastNameInput.isEmpty,
           !screenNameInput.isEmpty,
           !bioInput.isEmpty {
            isInputComplete = true
        } else {
            isInputComplete = false
        }
    }
    
    func submitInput() {
        guard let ifScreenNameTaken = ifScreenNameTaken else { return }
        firestoreHelper.createNewUser(
            firstName: firstNameInput,
            lastName: lastNameInput,
            screenName: screenNameInput,
            bio: bioInput,
            ifScreenNameTaken: ifScreenNameTaken
        )
    }
}
