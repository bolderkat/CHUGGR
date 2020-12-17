//
//  FriendDetailViewController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/16/20.
//

import UIKit

class FriendDetailViewController: UIViewController {

    private let viewModel: FriendDetailViewModel
    
    @IBOutlet weak var profPicView: UIImageView!
    @IBOutlet weak var drinksGivenLabel: UILabel!
    @IBOutlet weak var drinksReceivedLabel: UILabel!
    @IBOutlet weak var drinksOutstandingLabel: UILabel!
    @IBOutlet weak var friendsCountLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var tableControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    init(
        viewModel: FriendDetailViewModel,
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
        configureViewController()
    }
    
    func configureViewController() {
        // TODO: add user profile pic
        profPicView.image = UIImage(named: K.Images.profPicPlaceholder)
        drinksGivenLabel.text = viewModel.getDrinksString(forStat: .given)
        drinksReceivedLabel.text = viewModel.getDrinksString(forStat: .received)
        drinksOutstandingLabel.text = viewModel.getDrinksString(forStat: .outstanding)
        friendsCountLabel.text = String(viewModel.friend.numFriends)
        userNameLabel.text = viewModel.friend.userName
        bioLabel.text = viewModel.friend.bio
    }

}
