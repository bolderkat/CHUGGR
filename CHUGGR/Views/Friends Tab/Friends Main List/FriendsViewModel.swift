//
//  FriendsViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/12/20.
//

import Foundation

class FriendsViewModel {
    private let firestoreHelper: FirestoreHelper
    private var friendSnippets: [FriendSnippet] = []
    private(set) var cellVMs: [FriendCellViewModel] = [] {
        didSet {
            updateTableViewClosure?()
        }
    }
    private var searchResults: [FriendCellViewModel] = []
    private var isSearchBarEmpty = true
    
    var updateTableViewClosure: (() -> ())?
    var onFriendLoad: ((_ friend: FullFriend) -> ())?
    
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
        var vms = [FriendCellViewModel]()
        for snippet in friendSnippets {
            let vm = FriendCellViewModel(friend: snippet)
            vms.append(vm)
        }
        cellVMs = vms
    }
    
    func provideCellVMs(forString searchString: String) -> [FriendCellViewModel] {
        // Show entire friend list when user clears search bar
        if searchString == "" {
            isSearchBarEmpty = true
            return cellVMs
        } else {
            isSearchBarEmpty = false
            let string = searchString.lowercased() // case-insensitive search
            
            // Filter based on search string
            let results = cellVMs.filter {
                $0.firstName.lowercased().contains(string) ||
                    $0.lastName.lowercased().contains(string) ||
                    $0.userName.lowercased().contains(string) ||
                    "\($0.firstName) \($0.lastName)".lowercased().contains(string)
            }
            searchResults = results
            return results
        }
    }
    
    func getFriendUID(at indexPath: IndexPath) -> String {
        return isSearchBarEmpty ? friendSnippets[indexPath.row].uid : searchResults[indexPath.row].uid
    }
    
    func getFriend(withUID uid: UID) {
        guard let onFriendLoad = onFriendLoad else { return }
        firestoreHelper.getFriend(withUID: uid, completion: onFriendLoad)
    }
}
