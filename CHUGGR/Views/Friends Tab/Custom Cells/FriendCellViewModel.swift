//
//  FriendCellViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/15/20.
//

import Foundation

struct FriendCellViewModel {
    let friend: Friend
    var uid: UID
    var firstName: String
    var lastName: String
    var fullName: String
    var userName: String
    var searchName: String {
        // All names combined to facilitate faster, case-insensitive search
        (firstName + lastName + userName).lowercased()
    }
    let profilePic: String
    
    init(friend: Friend) {
        self.friend = friend
        self.uid = friend.uid
        self.firstName = friend.firstName
        self.lastName = friend.lastName
        self.fullName = "\(firstName) \(lastName)"
        self.userName = friend.userName
        self.profilePic = friend.profilePic
    }
    
}


extension FriendCellViewModel: Hashable {
    static func == (lhs: FriendCellViewModel, rhs: FriendCellViewModel) -> Bool {
        lhs.friend.uid == rhs.friend.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friend.uid)
    }
    
}
