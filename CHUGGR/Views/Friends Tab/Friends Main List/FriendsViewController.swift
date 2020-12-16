//
//  FriendsViewController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/12/20.
//

import UIKit

class FriendsViewController: UIViewController {

    weak var coordinator: FriendsCoordinator?
    private let viewModel: FriendsViewModel
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
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
        setUpViewController()

    }
    
    func setUpViewController() {
        title = "Friends"
        
        let addFriendButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addFriendPressed)
        )
        navigationItem.rightBarButtonItem = addFriendButtonItem
    }
    
    func initViewModel() {
        
    }
    
    @objc func addFriendPressed() {
        coordinator?.addFriend()
    }

}
