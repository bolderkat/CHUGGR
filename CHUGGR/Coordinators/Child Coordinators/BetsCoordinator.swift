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
        
        // Configure nav controller appearance
        self.navigationController.navigationBar.barTintColor = UIColor(named: K.colors.orange)
        self.navigationController.navigationBar.isTranslucent = false
        self.navigationController.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        navigationController.navigationBar.tintColor = .white
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
    
    func pop() {
        navigationController.popViewController(animated: true)
    }
    
    func openBetDetail(
        withBetID id: BetID,
        userInvolvement: BetInvolvementType = .uninvolved
    ) {
        let vm = BetDetailViewModel(firestoreHelper: firestoreHelper, userInvolvement: userInvolvement)
        vm.setBetDocID(withBetID: id)
        let vc = BetDetailViewController(viewModel: vm)
        vc.coordinator = self

        navigationController.pushViewController(vc, animated: true)
    }
    
    func openPendingBets() {
        let vc = PendingBetsViewController(viewModel: PendingBetsViewModel(firestoreHelper: firestoreHelper))
        vc.coordinator = self
        
        navigationController.pushViewController(vc, animated: true)
    }
}
