//
//  Coordinator.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/20/20.
//

import UIKit

protocol ParentCoordinating: AnyObject {
    var window: UIWindow { get set }
    var childCoordinators: [ChildCoordinating] { get set }
    func start()
}
