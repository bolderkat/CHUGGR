//
//  FriendsCoordinator.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/24/20.
//

import UIKit
import Firebase

class FriendsCoordinator: ChildCoordinating {
    weak var parentCoordinator: MainCoordinator?
    var childCoordinator = [ChildCoordinating]()
    let navigationController: UINavigationController
    let firestoreHelper: FirestoreHelper
    
    init(navigationController: UINavigationController,
         firestoreHelper: FirestoreHelper) {
        self.navigationController = navigationController
        self.firestoreHelper = firestoreHelper
        
        // Configure nav controller appearance
        self.navigationController.navigationBar.barTintColor = UIColor(named: K.colors.orange)
        self.navigationController.navigationBar.isTranslucent = false
        self.navigationController.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        navigationController.navigationBar.tintColor = .white
    }
    
    func start() {
        let vc = FriendsViewController(viewModel: FriendsViewModel(firestoreHelper: firestoreHelper))
        vc.coordinator = self
        vc.tabBarItem = UITabBarItem(
            title: "Following",
            image: UIImage(systemName: "person.3.fill"),
            tag: 1
        )
        navigationController.pushViewController(vc, animated: false)
    }
    
    func pop() {
        navigationController.popViewController(animated: true)
    }

    func openBetDetail(withBetID id: BetID) {
        let vm = BetDetailViewModel(firestoreHelper: firestoreHelper)
        vm.setBetDocID(withBetID: id)
        let vc = BetDetailViewController(viewModel: vm)
        vc.coordinator = self

        navigationController.pushViewController(vc, animated: true)
    }
    
    func addFriend() {
        let vm = AddFriendViewModel(firestoreHelper: firestoreHelper)
        let vc = AddFriendViewController(viewModel: vm)
        vc.coordinator = self
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showFriendDetail(for friend: FullFriend) {
        let vm = FriendDetailViewModel(firestoreHelper: firestoreHelper, friend: friend)
        let vc = FriendDetailViewController(viewModel: vm)
        vc.coordinator = self
        
        navigationController.pushViewController(vc, animated: true)
    }
}

