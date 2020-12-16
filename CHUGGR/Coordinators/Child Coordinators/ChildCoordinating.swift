//
//  ChildCoordinator.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/20/20.
//

import UIKit
import Firebase

protocol ChildCoordinating: AnyObject {
    var parentCoordinator: MainCoordinator? { get set }
    var childCoordinator: [ChildCoordinating] { get set }
    var navigationController: UINavigationController { get }
    var firestoreHelper: FirestoreHelper { get }
    
    func start()
    func pop()
    func openBetDetail(withBetID id: BetID)
}

