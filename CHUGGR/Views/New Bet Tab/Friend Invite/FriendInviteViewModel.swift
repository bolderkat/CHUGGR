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
    private(set) var selectedFriends: [FriendSnippet] = []
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
            var vm = InviteCellViewModel(friend: snippet)
            // Mark as checked if snippet is for a selected user
            if selectedFriends.contains(where: { $0 == snippet }) {
                vm.isChecked = true
            }
            vms.append(vm)
        }
        cellVMs = vms
    }
    
    func selectUser(at indexPath: IndexPath) {
        // TODO:  Will need logic to handle sections once Recents are implemented
        cellVMs[indexPath.row].isChecked.toggle()
        
        let selectedCellVM = cellVMs[indexPath.row]
        // Handle selection of user
        if selectedCellVM.isChecked {
            selectedFriends.append(selectedCellVM.friend)
        } else {
            // Remove from selectedFriends if unchecking
            if let index = selectedFriends.firstIndex(of: selectedCellVM.friend) {
                selectedFriends.remove(at: index)
            }
        }
        
        updateTableViewClosure?()
    }
    
}
