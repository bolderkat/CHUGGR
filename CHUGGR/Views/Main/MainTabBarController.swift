//
//  MainTabBarController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/22/20.
//

import UIKit

class MainTabBarController: UITabBarController {

    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = 0
        tabBar.tintColor = UIColor(named: K.colors.orange)
        tabBar.unselectedItemTintColor = .black
        
    }
}
