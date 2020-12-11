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
    let firestoreHelper: FirestoreHelper
    
    init?(window: UIWindow?, firestoreHelper: FirestoreHelper) {
        guard let window = window else { return nil } // fail init if no window
        self.window = window
        self.firestoreHelper = firestoreHelper
    }
    
    func start() {
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
        UIView.transition(
            with: window,
            duration: 0.8,
            options: .transitionCurlUp, // TODO: get a better animation... or don't 😇
            animations: nil,
            completion: nil)
    }
    
    func startTabBarCoordinators() {
        childCoordinators = [
            BetsCoordinator(navigationController: UINavigationController(),
                            firestoreHelper: firestoreHelper),
            FriendsCoordinator(navigationController: UINavigationController(),
                               firestoreHelper: firestoreHelper),
            NewBetsCoordinator(navigationController: UINavigationController(),
                               firestoreHelper: firestoreHelper),
            VideosCoordinator(navigationController: UINavigationController(),
                              firestoreHelper: firestoreHelper),
            ProfileCoordinator(navigationController: UINavigationController(),
                               firestoreHelper: firestoreHelper)
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
