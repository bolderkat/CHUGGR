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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        betsCoordinator.parentCoordinator = coordinator
        betsCoordinator.start()
        viewControllers = [betsCoordinator.navigationController]
    }

}
