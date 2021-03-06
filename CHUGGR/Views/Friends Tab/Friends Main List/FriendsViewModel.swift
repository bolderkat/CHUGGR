//
//  FriendsViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/12/20.
//

import Foundation

class FriendsViewModel {
    private let firestoreHelper: FirestoreHelping
    private var friendSnippets: [FriendSnippet] = []
    private(set) var cellVMs: [FriendCellViewModel] = [] {
        didSet {
            didUpdateFriendCellVMs?()
        }
    }
    private var searchResults: [FriendCellViewModel] = []
    private var isSearchBarEmpty = true
    
    var didUpdateFriendCellVMs: (() -> Void)?
    var onFriendLoad: ((_ friend: FullFriend) -> Void)?
    
    init(firestoreHelper: FirestoreHelping) {
        self.firestoreHelper = firestoreHelper
    }
    
    func fetchFriends() {
        // Add listener if not yet present
        firestoreHelper.addFriendsListener { [weak self] (snippets) in
            self?.friendSnippets = snippets
            self?.createCellVMs()
        }
        // Update from array attached to listener
        friendSnippets = firestoreHelper.friends
        createCellVMs()
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
