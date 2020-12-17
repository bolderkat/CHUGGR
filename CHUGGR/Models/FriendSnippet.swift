//
//  FriendSnippet.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/16/20.
//

import Foundation

struct FriendSnippet: Codable {
    // For user friend list subcollections
    let uid: UID
    let firstName: String
    let lastName: String
    let userName: String
    let profilePic: String
    
    init(fromFriend friend: Friend) {
        self.uid = friend.uid
        self.firstName = friend.firstName
        self.lastName = friend.lastName
        self.userName = friend.userName
        self.profilePic = friend.profilePic
    }
    
    init(fromCurrentUser user: CurrentUser) {
        self.uid = user.uid
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.userName = user.userName
        self.profilePic = user.profilePic
    }
}
