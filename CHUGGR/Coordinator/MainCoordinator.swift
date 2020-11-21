//
//  MainCoordinator.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/20/20.
//

import UIKit

class MainCoordinator: ParentCoordinating {
    var window: UIWindow?
    var childCoordinators = [ChildCoordinating]()
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        window?.rootViewController = WelcomeViewController.instantiate()
        window?.makeKeyAndVisible()
    }
}
