//
//  InviteCellViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/17/20.
//

import Foundation

struct InviteCellViewModel {
    let friend: FriendSnippet
    var uid: UID
    var firstName: String
    var lastName: String
    var fullName: String
    var userName: String
    let profilePic: String
    var isChecked = false
    
    init(friend: FriendSnippet) {
        self.friend = friend
        self.uid = friend.uid
        self.firstName = friend.firstName
        self.lastName = friend.lastName
        self.fullName = "\(firstName) \(lastName)"
        self.userName = friend.userName
        self.profilePic = friend.profilePic
    }
    
}


extension InviteCellViewModel: Hashable {
    static func == (lhs: InviteCellViewModel, rhs: InviteCellViewModel) -> Bool {
        lhs.friend.uid == rhs.friend.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friend.uid)
    }
    
}

