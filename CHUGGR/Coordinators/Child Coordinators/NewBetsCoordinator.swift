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
        let vc = FriendInviteViewController(
            viewModel: FriendInviteViewModel(
                firestoreHelper: firestoreHelper
            )
        )
        vc.coordinator = self
        vc.tabBarItem = UITabBarItem(
            title: "New Bet",
            image: UIImage(systemName: "plus.circle.fill"),
            tag: 2
        ) 
        navigationController.pushViewController(vc, animated: false)
    }
    
    func pop() {
        navigationController.popViewController(animated: true)
    }
    
    func goToBetEntry(inviting friends: [FriendSnippet]) {
        let vm = NewBetViewModel(firestoreHelper: firestoreHelper, invitedFriends: friends)
        let vc = NewBetViewController(viewModel: vm)
        vc.coordinator = self
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func openBetDetail(
        withBetID id: BetID,
        userInvolvement: BetInvolvementType = .uninvolved
    ) {
        let vm = BetDetailViewModel(
            firestoreHelper: firestoreHelper,
            betID: id,
            userInvolvement: userInvolvement
        )
        let vc = BetDetailViewController(viewModel: vm)
        vc.coordinator = self

        navigationController.pushViewController(vc, animated: true)
    }

}
