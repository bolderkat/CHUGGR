//
//  UserDetailEntryViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/10/20.
//

import Foundation
import Firebase
class UserDetailEntryViewModel {
    private let firestoreHelper: FirestoreHelping
    private(set) var cellViewModels = [UserDetailEntryCellViewModel]() {
        didSet {
            reloadTableViewClosure?()
        }
    }
    
    private(set) var firstNameInput = ""
    private(set) var lastNameInput = ""
    private(set) var userNameInput = ""
    private(set) var bioInput = ""
    
    var reloadTableViewClosure: (() -> Void)?
    var updateButtonStatus: ((Bool) -> ())?
    var ifUserNameTaken: (() -> Void)?
    var onUserLoad: (() -> Void)? // notes from ian call: pass result type or bool as closure parameter
    
    init(firestoreHelper: FirestoreHelping) {
        self.firestoreHelper = firestoreHelper
    }
    
    func createCellVMs() {
        let rowTypes = [
            UserEntryRowType.firstName,
            UserEntryRowType.lastName,
            UserEntryRowType.userName,
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
        case .userName:
            userNameInput = text
        case .bio:
            bioInput = text
        }
        validateInput()
    }
    
    func validateInput() {
        guard let updateButtonStatus = updateButtonStatus else { return }
        // Make sure all fields have input before marking input complete
        if !firstNameInput.isEmpty,
           !lastNameInput.isEmpty,
           !userNameInput.isEmpty,
           !bioInput.isEmpty {
            // Return a bool via closure reflecting validity of user's input
            updateButtonStatus(true)
        } else {
            updateButtonStatus(false)
        }
    }
    
    func submitInput() {
        guard let ifUserNameTaken = ifUserNameTaken else { return }
        firestoreHelper.createNewUser(
            firstName: firstNameInput,
            lastName: lastNameInput,
            userName: userNameInput,
            bio: bioInput,
            ifUserNameTaken: ifUserNameTaken,
            completion: onUserLoad
        )
    }
}
