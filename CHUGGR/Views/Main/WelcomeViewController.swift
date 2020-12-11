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
    private var viewModel: WelcomeViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Skip auth if user already logged in.
        if let uid = Auth.auth().currentUser?.uid {
            viewModel?.getCurrentUserDetails(with: uid)
            
            // TODO: display loading indicator if needed?
        }
    }
    
    func setViewModel(_ viewModel: WelcomeViewModel) {
        self.viewModel = viewModel
    }
    
    func initViewModel() {
        viewModel?.onUserRead = continueWhenUserPresent
        viewModel?.onUserReadFail = userReadDidFail
    }

    private func continueWhenUserPresent() {
        // Call coordinator to go to tab bar controller
        if let coordinator = mainCoordinator {
            coordinator.goToTabBar()
        }
    }
    
    private func userReadDidFail() {
        // TODO: fail more gracefully
        fatalError("Failed to read user from DB")
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

