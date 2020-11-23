//
//  ChildCoordinator.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/20/20.
//

import UIKit

protocol ChildCoordinating: AnyObject {
    var parentCoordinator: MainCoordinator? { get set }
    var childCoordinator: [ChildCoordinating] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

