//
//  WelcomeViewController.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/5/20.
//

import UIKit
import Firebase
import FirebaseUI

class WelcomeViewController: UIViewController {
    
    var mainCoordinator: MainCoordinator?
    private var viewModel: WelcomeViewModel
    
    @IBOutlet weak var getStartedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
        continueIfLoggedIn()
        getStartedButton.layer.cornerRadius = 15
    }
    
    init(
        viewModel: WelcomeViewModel,
         nibName: String? = nil,
         bundle: Bundle? = nil
    ) {
        self.viewModel = viewModel
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViewModel() {
        viewModel.onUserRead = proceedToDashboard
        viewModel.onUserDocNotFound = onUserDocNotFound
        viewModel.onUserReadFail = userReadDidFail
    }
    
    func continueIfLoggedIn() {
        // Check auth status.
        if let uid = Auth.auth().currentUser?.uid {
            viewModel.getCurrentUserDetails(with: uid)
            // if doc not found, go to user details
            // TODO: display loading indicator if needed?
        }
    }

    private func proceedToDashboard() {
        // Call coordinator to go to tab bar controller
        if let coordinator = mainCoordinator {
            coordinator.goToTabBar()
        }
    }
    
    private func onUserDocNotFound() {
        if let coordinator = mainCoordinator {
            coordinator.presentUserDetailEntry()
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
        continueIfLoggedIn()
    }

}

