//
//  FriendInviteViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/17/20.
//

import Foundation

class FriendInviteViewModel {
    private let firestoreHelper: FirestoreHelper
    private var friendSnippets: [FriendSnippet] = []
    private(set) var cellVMs: [InviteCellViewModel] = [] {
        didSet {
            updateTableViewClosure?()
        }
    }
    private var isSearchBarEmpty = true
    
    var updateTableViewClosure: (() -> ())?
    
    init(firestoreHelper: FirestoreHelper) {
        self.firestoreHelper = firestoreHelper
    }
    
    func fetchFriends() {
        // Set up listener if there is not yet one
        if firestoreHelper.friendsListener == nil {
            firestoreHelper.addFriendsListener { [weak self] (snippets) in
                self?.friendSnippets = snippets
                self?.createCellVMs()
            }
        } else {
            // Otherwise we can just read from the array which is already being updated in real-time
            friendSnippets = firestoreHelper.friends
            createCellVMs()
        }
    }
    
    func createCellVMs() {
        var vms = [InviteCellViewModel]()
        for snippet in friendSnippets {
            let vm = InviteCellViewModel(friend: snippet)
            vms.append(vm)
        }
        cellVMs = vms
    }
    
}
