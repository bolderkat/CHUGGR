//
//  FriendCellViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/15/20.
//

import Foundation

struct FriendCellViewModel: Hashable {
    let uid: UID
    let firstName: String
    let lastName: String
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    var searchName: String {
        // All names combined to facilitate faster, case-insensitive search
        (firstName + lastName + screenName).lowercased()
    }
    let screenName: String
}
