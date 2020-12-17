//
//  AddFriendsViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/15/20.
//

import Foundation

class AddFriendViewModel {
    private let firestoreHelper: FirestoreHelper
    private(set) var potentialFriends: [FullFriend] = []
    private var friendCellVMs: [FriendCellViewModel] = []
    private var searchResults: [FriendCellViewModel] = []
    private(set) var isLoading = false {
        didSet {
            updateLoadingStatus?()
        }
    }
    
    var updateLoadingStatus: (() -> ())?
    
    init(firestoreHelper: FirestoreHelper) {
        self.firestoreHelper = firestoreHelper
    }
    
    func initFetchAllUsers() {
        isLoading = true
        firestoreHelper.addAllUserListener { [weak self] users in
            self?.potentialFriends = users.sorted { $0.firstName < $1.firstName }
            self?.createCellVMs()
            self?.isLoading = false
        }
    }
    
    func createCellVMs() {
        var vms = [FriendCellViewModel]()
        for user in potentialFriends {
            let vm = FriendCellViewModel(friend: user)
            vms.append(vm)
        }
        friendCellVMs = vms
    }
    
    func provideCellVMs(forString searchString: String) -> [FriendCellViewModel] {
        let string = searchString.lowercased() // case-insensitive search
        searchResults = friendCellVMs.filter { $0.searchName.contains(string) }
        return searchResults
    }
    
    func getSelectedFriend(at indexPath: IndexPath) -> FullFriend {
        guard let friend = searchResults[indexPath.row].friend as? FullFriend else {
            fatalError("Found FriendSnippet instead of FullFriend when retrieving friend from AddFriendViewModel search results")
        }
        return friend
    }
    
}

