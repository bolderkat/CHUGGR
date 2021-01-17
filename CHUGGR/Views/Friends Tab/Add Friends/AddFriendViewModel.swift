//
//  AddFriendsViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/15/20.
//

import Foundation

class AddFriendViewModel {
    private let firestoreHelper: FirestoreHelping
    private var friendUIDs: Set<UID> {
        // Used so already added users do not appear in search
        Set(firestoreHelper.friends.map { $0.uid })
    }
    private(set) var allUserVMs: [FriendCellViewModel] = [] {
        didSet {
            // Check search bar status so table view is only updated with all users if search bar is empty. Allows for persistence of search queries when user navigates to different tab and back.
            if isSearchBarEmpty {
                didUpdateUserVMs?()
            }
        }
    }
    private var searchResults: [FriendCellViewModel] = []
    private var isSearchBarEmpty = true
    private(set) var isLoading = false {
        didSet {
            didChangeloadingStatus?()
        }
    }
    
    var didUpdateUserVMs: (() -> Void)?
    var didChangeloadingStatus: (() -> Void)?
    var onFriendFetch: ((FullFriend) -> Void)?
    
    init(firestoreHelper: FirestoreHelping) {
        self.firestoreHelper = firestoreHelper
    }
    
    func initSetUpAllUserListener() {
        isLoading = true
        firestoreHelper.addAllUserListener { [weak self] in
            self?.createCellVMs()
            self?.isLoading = false
        }
    }
    
    func createCellVMs() {
        var vms = [FriendCellViewModel]()
        let nonFriendUsers = firestoreHelper.allUsers.filter { !friendUIDs.contains($0.uid) }
        for user in nonFriendUsers {
            let vm = FriendCellViewModel(friend: user)
            vms.append(vm)
        }
        allUserVMs = vms
    }
    
    func provideCellVMs(forString searchString: String) -> [FriendCellViewModel] {
        if searchString == "" {
            isSearchBarEmpty = true
            return allUserVMs
        } else {
            isSearchBarEmpty = false
            let string = searchString.lowercased() // case-insensitive search
            let userSearchResults = allUserVMs.filter {
                $0.firstName.lowercased().contains(string) ||
                    $0.lastName.lowercased().contains(string) ||
                    $0.userName.lowercased().contains(string) ||
                    "\($0.firstName) \($0.lastName)".lowercased().contains(string)
            }
            searchResults = userSearchResults
            return userSearchResults
        }
    }
    
    func provideSelectedFriend(at indexPath: IndexPath) -> FullFriend {
        let selectedFriend = isSearchBarEmpty ? allUserVMs[indexPath.row].friend : searchResults[indexPath.row].friend
        guard let friend = selectedFriend as? FullFriend else {
            fatalError("Found FriendSnippet instead of FullFriend when retrieving friend from AddFriendViewModel search results")
        }
        return friend
    }
    
    func getFreshData(for friend: FullFriend) {
        firestoreHelper.getFriend(withUID: friend.uid) { [weak self] friend in
            self?.onFriendFetch?(friend)
        }
    }
    
}

