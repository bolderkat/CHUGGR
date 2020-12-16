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
    let userName: String
    var searchName: String {
        // All names combined to facilitate faster, case-insensitive search
        (firstName + lastName + userName).lowercased()
    }
    let profilePic: String = "" // TODO: populate with actual url later
}