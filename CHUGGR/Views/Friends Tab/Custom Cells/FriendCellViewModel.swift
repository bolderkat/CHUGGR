//
//  FriendCellViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/15/20.
//

import Foundation

struct FriendCellViewModel {
    let friend: Friend
    var uid: UID { friend.uid }
    var firstName: String { friend.firstName }
    var lastName: String { friend.lastName }
    var fullName: String { "\(firstName) \(lastName)" }
    var userName: String { friend.userName }
    var searchName: String {
        // All names combined to facilitate faster, case-insensitive search
        (firstName + lastName + userName).lowercased()
    }
    let profilePic: String = "" // TODO: populate with actual url later
}


extension FriendCellViewModel: Hashable {
    static func == (lhs: FriendCellViewModel, rhs: FriendCellViewModel) -> Bool {
        lhs.friend.uid == rhs.friend.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friend.uid)
    }
    
}
