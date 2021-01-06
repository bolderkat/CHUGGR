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
    var didValidateInput: ((Bool) -> Void)?
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
        guard let didValidateInput = didValidateInput else { return }
        if !firstNameInput.isEmpty,
           !lastNameInput.isEmpty,
           !userNameInput.isEmpty,
           !bioInput.isEmpty {
            didValidateInput(true)
        } else {
            didValidateInput(false)
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
