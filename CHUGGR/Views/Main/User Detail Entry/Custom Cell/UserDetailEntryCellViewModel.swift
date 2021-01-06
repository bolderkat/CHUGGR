//
//  UserDetailEntryCellViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/10/20.
//

import Foundation

enum UserEntryRowType: String, Hashable, CaseIterable {
    // Conforms to CaseIterable for unit testing
    case firstName = "First Name"
    case lastName = "Last Name"
    case userName = "Username"
    case bio = "Bio"
}

struct UserDetailEntryCellViewModel: Hashable {
    let type: UserEntryRowType
    let title: String
    
    init(type: UserEntryRowType) {
        self.type = type
        self.title = type.rawValue
    }
}
