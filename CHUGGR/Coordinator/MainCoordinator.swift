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
        goToTabBar()
        
// Commenting out so I don't have to log in every time...
//        let vc = WelcomeViewController.instantiate()
//        vc.mainCoordinator = self
//        window.rootViewController = vc
//        window.makeKeyAndVisible()
    }
    
    func goToTabBar() {
        let tabController = MainTabBarController()
        tabController.coordinator = self
        startTabBarCoordinators()
        tabController.viewControllers = childCoordinators.map { $0.navigationController }
        window.rootViewController = tabController
        UIView.transition(
            with: window,
            duration: 0.8,
            options: .transitionCurlUp, // TODO: get a better animation... or don't 😇
            animations: nil,
            completion: nil)
    }
    
    func startTabBarCoordinators() {
        childCoordinators = [
            BetsCoordinator(navigationController: UINavigationController()),
            FriendsCoordinator(navigationController: UINavigationController()),
            NewBetsCoordinator(navigationController: UINavigationController()),
            VideosCoordinator(navigationController: UINavigationController()),
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
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil)
    }
}
