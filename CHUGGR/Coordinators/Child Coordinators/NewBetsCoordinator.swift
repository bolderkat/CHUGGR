//
//  NewBetsCoordinator.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/24/20.
//

import UIKit
import Firebase

class NewBetsCoordinator: ChildCoordinating {
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
        let vc = NewBetViewController.instantiate()
        vc.coordinator = self
        vc.tabBarItem = UITabBarItem(
            title: "New Bet",
            image: UIImage(systemName: "plus.circle.fill"),
            tag: 2
        )
        
        let vm = NewBetViewModel(firestoreHelper: firestoreHelper)
        vc.setViewModel(vm)
        
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
