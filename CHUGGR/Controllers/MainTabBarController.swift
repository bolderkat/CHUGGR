//
//  MainTabBarController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/22/20.
//

import UIKit

class MainTabBarController: UITabBarController {

    weak var coordinator: MainCoordinator?
    
    let betsCoordinator = BetsCoordinator(navigationController: UINavigationController())
    let profileCoordinator = ProfileCoordinator(navigationController: UINavigationController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [betsCoordinator.navigationController, profileCoordinator.navigationController]
        startBets()
        startProfile()
        selectedIndex = 0
    }
    
    func startBets() {
        betsCoordinator.parentCoordinator = coordinator
        betsCoordinator.start()
    }
    
    func startProfile() {
        profileCoordinator.parentCoordinator = coordinator
        profileCoordinator.start()
    }

}
