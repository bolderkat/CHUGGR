//
//  VideosCoordinator.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/24/20.
//

import UIKit
import Firebase

class VideosCoordinator: ChildCoordinating {
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
        let vc = VideosViewController.instantiate()
        vc.coordinator = self
        vc.tabBarItem = UITabBarItem(
            title: "Videos",
            image: UIImage(systemName: "video.fill"),
            tag: 3
        )
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
