//
//  ProfileCoordinator.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/23/20.
//

import UIKit
import Firebase

class ProfileCoordinator: ChildCoordinating {
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
        let vc = ProfileViewController.instantiate()
        vc.coordinator = self
        vc.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.circle.fill"),
            tag: 4
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

