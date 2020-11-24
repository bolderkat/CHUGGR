//
//  FriendsCoordinator.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/24/20.
//

import UIKit

class FriendsCoordinator: ChildCoordinating {
    weak var parentCoordinator: MainCoordinator?
    var childCoordinator = [ChildCoordinating]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
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
}

