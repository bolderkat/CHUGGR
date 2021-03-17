//
//  SceneDelegate.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/5/20.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: MainCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        // Pass control of window to MainCoordinator
        coordinator = MainCoordinator(window: window)
        coordinator?.start()
        coordinator?.setUpTabBarAndCoordinators()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        window?.endEditing(true)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

}

