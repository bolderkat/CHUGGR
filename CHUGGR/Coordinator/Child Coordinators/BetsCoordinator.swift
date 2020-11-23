//
//  BetsCoordinator.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/23/20.
//

import UIKit

class BetsCoordinator: ChildCoordinating {
    weak var parentCoordinator: MainCoordinator?
    var childCoordinator = [ChildCoordinating]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = BetsViewController.instantiate()
        vc.coordinator = self
        vc.tabBarItem = UITabBarItem(
            title: "Bets",
            image: UIImage(systemName: "exclamationmark.bubble.fill"),
            tag: 0
        )
        navigationController.pushViewController(vc, animated: false)
    }
}
