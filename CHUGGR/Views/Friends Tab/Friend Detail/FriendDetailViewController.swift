//
//  FriendDetailViewController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/16/20.
//

import UIKit

class FriendDetailViewController: UIViewController {
    
    weak var coordinator: FriendsCoordinator?
    private let viewModel: FriendDetailViewModel
    
    @IBOutlet weak var profPicView: UIImageView!
    @IBOutlet weak var drinksGivenLabel: UILabel!
    @IBOutlet weak var drinksReceivedLabel: UILabel!
    @IBOutlet weak var drinksOutstandingLabel: UILabel!
    @IBOutlet weak var friendsCountLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var realNameLabel: UILabel!
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
        initViewModel()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        viewModel.checkFriendStatus()
//    }
    
    func configureViewController() {
        updateLabels()
        
        // Disable add friend button until status is verified
//        addFriendButton.isEnabled = false
//        addFriendButton.backgroundColor = UIColor(named: K.colors.gray5)
//        addFriendButton.setTitle("Loading...", for: .disabled)
    }
    
    func updateLabels() {
        // TODO: add user profile pic
        profPicView.image = UIImage(named: K.Images.profPicPlaceholder)
        drinksGivenLabel.text = viewModel.getDrinksString(forStat: .given)
        drinksReceivedLabel.text = viewModel.getDrinksString(forStat: .received)
        drinksOutstandingLabel.text = viewModel.getDrinksString(forStat: .outstanding)
        friendsCountLabel.text = String(viewModel.friend.numFriends)
        userNameLabel.text = viewModel.friend.userName
        realNameLabel.text = "\(viewModel.friend.firstName) \(viewModel.friend.lastName)"
        bioLabel.text = viewModel.friend.bio

    }
    
    func initViewModel() {
        viewModel.updateVCLabels = { [weak self] in
            DispatchQueue.main.async {
                self?.updateLabels()
            }
        }
        
        viewModel.setVCForFriendStatus = { [weak self] in
            DispatchQueue.main.async {
                self?.configureForFriendStatus()
            }
        }
        viewModel.checkFriendStatus()
    }
    
    func configureForFriendStatus() {
        if viewModel.isAlreadyFriends {
            // TODO: button goes to DMs when already friends
            addFriendButton.isEnabled = false
            addFriendButton.backgroundColor = UIColor(named: K.colors.gray5)
            addFriendButton.setTitle("Friend added!", for: .disabled)
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "ellipsis.circle.fill"),
                style: .plain,
                target: self,
                action: #selector(showFriendOptions)
            )
        } else {
            addFriendButton.isEnabled = true
            addFriendButton.setTitle("Add Friend", for: .normal)
            addFriendButton.backgroundColor = UIColor(named: K.colors.orange)
            navigationItem.rightBarButtonItem = nil
        }
    }

    @IBAction func addFriendPressed(_ sender: UIButton) {
        viewModel.addFriend()
    }
    
    @objc func showFriendOptions() {
        
    }
    
}
