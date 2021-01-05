//
//  FriendInviteViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/17/20.
//

import Foundation

class FriendInviteViewModel {
    private let firestoreHelper: FirestoreHelping
    private var friendSnippets: [FriendSnippet] = []
    private(set) var cellVMs: [InviteCellViewModel] = [] {
        didSet {
            updateTableViewClosure?(searchString)
        }
    }
    private(set) var selectedFriends: [FriendSnippet] = [] {
        didSet {
            updateRecipientView?()
        }
    }
    private var searchResults: [InviteCellViewModel] = []
    private var isSearchBarEmpty = true
    private var searchString: String = ""
    
    var updateTableViewClosure: ((String) -> ())?
    var updateRecipientView: (() -> ())?
    
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
    
    func provideCellVMs(forString searchString: String) -> [InviteCellViewModel] {
        self.searchString = searchString
        // Show entire friend list when user clears search bar
        if searchString == "" {
            isSearchBarEmpty = true
            return cellVMs
        } else {
            isSearchBarEmpty = false
            let string = searchString.lowercased() // case-insensitive search. Can force unwrap as nil case is handled
            
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
    
    func selectUser(at indexPath: IndexPath) {
        // TODO:  Will need logic to handle sections once Recents are implemented
        
        var selectedIndex = indexPath.row
        
        // If user has searched, indexPath won't match full cellVM array. Get the correct index for full array
        if !isSearchBarEmpty {
            let selectedFriend = searchResults[indexPath.row]
            if let index = cellVMs.firstIndex(of: selectedFriend) {
                selectedIndex = index
            }
        }
        
        cellVMs[selectedIndex].isChecked.toggle()
        
        let selectedCellVM = cellVMs[selectedIndex]
        
        // Handle selection of user
        if selectedCellVM.isChecked {
            selectedFriends.append(selectedCellVM.friend)
        } else {
            // Remove from selectedFriends if unchecking
            if let index = selectedFriends.firstIndex(of: selectedCellVM.friend) {
                selectedFriends.remove(at: index)
            }
        }
        updateTableViewClosure?(searchString)
    }
    
    
    func getRecipientNames() -> String {
        switch selectedFriends.count {
        case 0:
            return ""
        case 1:
            return "\(selectedFriends[0].firstName) \(selectedFriends[0].lastName)"
        case _ where selectedFriends.count > 1:
            var namesArray = [String]()
            for friend in selectedFriends {
                let fullName = "\(friend.firstName) \(friend.lastName)"
                namesArray.append(fullName)
            }
            return namesArray.joined(separator: ", ")
        default:
            // This case should be impossible
            return ""
        }
    }
    
}
