//
//  MainCoordinator.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/20/20.
//

import UIKit

class MainCoordinator: ParentCoordinating {
    var window: UIWindow
    var childCoordinators = [ChildCoordinating]()
    
    init?(window: UIWindow?) {
        guard let window = window else { return nil } // fail init if no window
        self.window = window
    }
    
    func start() {
//        goToTabBar()
        
        let vc = WelcomeViewController.instantiate()
        vc.mainCoordinator = self
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
    
    func goToTabBar() {
        let tabController = MainTabBarController()
        tabController.coordinator = self
        startTabBarCoordinators()
        tabController.viewControllers = childCoordinators.map { $0.navigationController }
        window.rootViewController = tabController
    }
    
    func startTabBarCoordinators() {
        childCoordinators = [
            BetsCoordinator(navigationController: UINavigationController()),
            ProfileCoordinator(navigationController: UINavigationController())
        ]
        childCoordinators.forEach {
            $0.parentCoordinator = self
            $0.start()
        }
    }
    
    func logOut() {
        let vc = WelcomeViewController.instantiate()
        vc.mainCoordinator = self
        window.rootViewController = vc
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil)
    }
}
