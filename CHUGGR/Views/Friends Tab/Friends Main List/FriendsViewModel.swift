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
    
    var updateTableViewClosure: (() -> ())?
    var onFriendLoad: ((_ friend: FullFriend) -> ())?
    
    init(firestoreHelper: FirestoreHelper) {
        self.firestoreHelper = firestoreHelper
    }
    
    func setUpFriendsListener() {
        firestoreHelper.addFriendsListener { [weak self] (snippets) in
            self?.friendSnippets = snippets
            self?.createCellVMs()
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
    
    func getFriendUID(at indexPath: IndexPath) -> String {
        return friendSnippets[indexPath.row].uid
    }
    
    func getFriend(withUID uid: UID) {
        guard let onFriendLoad = onFriendLoad else { return }
        firestoreHelper.getFriend(withUID: uid, completion: onFriendLoad)
    }
}
