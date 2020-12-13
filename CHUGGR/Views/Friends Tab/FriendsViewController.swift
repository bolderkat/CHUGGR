//
//  FriendsViewController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/12/20.
//

import UIKit

class FriendsViewController: UIViewController {

    weak var coordinator: ChildCoordinating?
    private let viewModel: FriendsViewModel
    
    init(
        viewModel: FriendsViewModel,
        nibName: String? = nil,
        bundle: Bundle? = nil
    ) {
        self.viewModel = viewModel
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
