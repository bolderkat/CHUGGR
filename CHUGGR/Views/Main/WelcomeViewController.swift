//
//  WelcomeViewController.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/5/20.
//

import UIKit
import Firebase
import FirebaseUI

class WelcomeViewController: UIViewController, Storyboarded {
    
    var mainCoordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Skip auth if user already logged in.
        if let _ = Auth.auth().currentUser?.uid {
            continueWhenUserPresent()
        }
    }

    // Auth persistence from https://stackoverflow.com/questions/48561643/firebase-login-persistence-swift
    private func continueWhenUserPresent() {
        // Call coordinator to go to tab bar controller
        if let coordinator = mainCoordinator {
            coordinator.goToTabBar()
        }
    }
    
    @IBAction func getStartedPressed(_ sender: UIButton) {
        guard let authUI = FUIAuth.defaultAuthUI() else {
            print("Error initializing Firebase Auth UI")
            return
        }
        authUI.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIEmailAuth()
        ]
        authUI.providers = providers
        let authViewController = authUI.authViewController()
        present(authViewController, animated: true, completion: nil)
    }

    @IBAction func unwindToWelcomeViewController(unwindSegue: UIStoryboardSegue) {}

}

extension WelcomeViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        guard error == nil else {
            print(String(describing: error))
            return
        }
        continueWhenUserPresent()
    }
}
