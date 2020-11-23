//
//  ProfileCoordinator.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/23/20.
//

import UIKit

class ProfileCoordinator: ChildCoordinating {
    weak var parentCoordinator: MainCoordinator?
    var childCoordinator = [ChildCoordinating]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = ProfileViewController.instantiate()
        vc.coordinator = self
        vc.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.circle.fill"),
            tag: 1 // TODO: change to 4 when other tabs are added
        )
        navigationController.pushViewController(vc, animated: false)
    }
}

