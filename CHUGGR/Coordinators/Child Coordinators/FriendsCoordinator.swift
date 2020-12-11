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
    }
    
    func start() {
        let vc = FriendsViewController.instantiate()
        vc.coordinator = self
        vc.tabBarItem = UITabBarItem(
            title: "Friends",
            image: UIImage(systemName: "person.3.fill"),
            tag: 1
        )
        navigationController.pushViewController(vc, animated: false)
    }

    func openBetDetail(withBetID id: BetID) {
        let vc = BetsDetailViewController.instantiate()
        vc.coordinator = self
        
        let vm = BetsDetailViewModel(firestoreHelper: firestoreHelper)
        vm.setBetDocID(withBetID: id)
        vc.setViewModel(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}

