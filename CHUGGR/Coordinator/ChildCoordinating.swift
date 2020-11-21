//
//  ChildCoordinator.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/20/20.
//

import UIKit

protocol ChildCoordinating: AnyObject {
    var parentCoordinator: ParentCoordinating? { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

