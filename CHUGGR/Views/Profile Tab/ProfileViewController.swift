//
//  ProfileViewController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/11/20.
//

import UIKit

class ProfileViewController: UIViewController {
    
    weak var coordinator: ChildCoordinating?
    private let viewModel: ProfileViewModel
   
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        self.navigationItem.rightBarButtonItem = .init(
            title: "Log Out",
            style: .plain,
            target: self,
            action: #selector(logOutPressed)
        )
    }
    
    init(viewModel: ProfileViewModel,
         nibName: String? = nil,
         bundle: Bundle? = nil
    ) {
        self.viewModel = viewModel
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    @objc func logOutPressed() {
        viewModel.logOut()
        if let coordinator = coordinator, let mainCoordinator = coordinator.parentCoordinator {
            mainCoordinator.logOut()
        }
    }
    
}
