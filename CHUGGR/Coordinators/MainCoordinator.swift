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
    let firestoreHelper = FirestoreHelper()
    let tabController = MainTabBarController()
    
    init?(window: UIWindow?) {
        guard let window = window else { return nil } // fail init if no window
        self.window = window
    }
    
    func start() {
        let vc = WelcomeViewController(
            viewModel: WelcomeViewModel(firestoreHelper: firestoreHelper)
        )
        vc.mainCoordinator = self
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
    
    func start(fromNotification category: NotificationCategory) {
        switch category {
        case .newBet:
            tabController.selectedIndex = 0
            if let coordinator = childCoordinators[0] as? BetsCoordinator {
                coordinator.openPendingBets()
            }
        default:
            return
        }
    }
    
    func presentUserDetailEntry() {
        let vc = UserDetailEntryViewController(
            viewModel: UserDetailEntryViewModel(firestoreHelper: firestoreHelper)
        )
        vc.mainCoordinator = self
        UIView.transition(
            with: window,
            duration: 0.5,
            options: .transitionFlipFromRight,
            animations: nil,
            completion: nil)
        window.rootViewController = vc
    }
    
    func goToTabBar() {
        tabController.selectedIndex = 0
        UIView.transition(
            with: window,
            duration: 0.8,
            options: .transitionCurlUp,
            animations: nil,
            completion: nil)
        window.rootViewController = tabController
    }
    
    func setUpTabBarAndCoordinators() {
        tabController.coordinator = self
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
        tabController.viewControllers = childCoordinators.map { $0.navigationController }
    }
    
    func openNewBetDetail(with id: BetID) {
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )
        tabController.selectedIndex = 0
        childCoordinators[0].openBetDetail(withBetID: id, userInvolvement: .accepted)
    }
    
    func logOut() {
        let vc = WelcomeViewController(
            viewModel: WelcomeViewModel(firestoreHelper: firestoreHelper)
        )
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
