//
//  BetsCoordinator.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/23/20.
//

import UIKit
import Firebase

class BetsCoordinator: ChildCoordinating {
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
        let vc = BetsViewController(viewModel: BetsViewModel(firestoreHelper: firestoreHelper))
        vc.coordinator = self
        vc.tabBarItem = UITabBarItem(
            title: "Bets",
            image: UIImage(systemName: "exclamationmark.bubble.fill"),
            tag: 0
        )
        navigationController.pushViewController(vc, animated: false)
    }
    
    func openBetDetail(withBetID id: BetID) {
        let vm = BetDetailViewModel(firestoreHelper: firestoreHelper)
        vm.setBetDocID(withBetID: id)
        let vc = BetDetailViewController(viewModel: vm)
        vc.coordinator = self

        navigationController.pushViewController(vc, animated: true)
    }
}
