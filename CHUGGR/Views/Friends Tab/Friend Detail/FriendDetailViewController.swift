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
    private var dataSource: UITableViewDiffableDataSource<Section, BetCellViewModel>!
    private let scrollViewThreshold: CGFloat = 100.0 // threshold at which fetching additional bets is triggered
    
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
        configureDataSource()
        initViewModel()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.initFetchPastBets()
        viewModel.addActiveBetListeners()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.cleanUpFirestore()
    }
    
    func configureViewController() {
        updateLabels()
    }
    
    func updateLabels() {
        // TODO: add user profile pic
        title = viewModel.friend.userName
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
        viewModel.didUpdateFriend = { [weak self] in
            DispatchQueue.main.async {
                self?.updateLabels()
            }
        }
        
        viewModel.didReceiveFriendStatusChangeAction = { [weak self] in
            DispatchQueue.main.async {
                self?.configureForFriendStatus()
            }
        }
        
        viewModel.onBetUpdateOrTableChange = { [weak self] in
            DispatchQueue.main.async {
                self?.updateTableView()
            }
        }
        viewModel.setFriendListener()
        viewModel.checkFriendStatus()
        
    }
    
    
    
    func configureForFriendStatus() {
        if viewModel.isAlreadyFriends {
            // TODO: button goes to DMs when already friends
            addFriendButton.isEnabled = false
            addFriendButton.backgroundColor = UIColor(named: K.colors.gray5)
            addFriendButton.setTitle("Already following", for: .disabled)
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "ellipsis.circle.fill"),
                style: .plain,
                target: self,
                action: #selector(showFriendOptions)
            )
        } else {
            addFriendButton.isEnabled = true
            addFriendButton.setTitle("Follow", for: .normal)
            addFriendButton.backgroundColor = UIColor(named: K.colors.orange)
            navigationItem.rightBarButtonItem = nil
        }
    }

    @IBAction func addFriendPressed(_ sender: UIButton) {
        viewModel.addFriend()
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            viewModel.selectedTable = .active
        } else if sender.selectedSegmentIndex == 1 {
            viewModel.selectedTable = .pastBets
        }
    }
    
    @objc func showFriendOptions() {
        guard viewModel.isRemoveButtonActive else { return }
        let alert = UIAlertController(
            title: "Unfollow user?",
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "Unfollow",
                style: .destructive
            ) { [weak self] _ in
                self?.viewModel.removeFriend()
            })
        present(alert, animated: true)
        
        
    }
    
}

// MARK:- TableView Data Source
extension FriendDetailViewController {
    enum Section {
        case main
    }
    
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, BetCellViewModel>(
            tableView: tableView) { (tableView, indexPath, rowVM) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: K.cells.betCell,
                    for: indexPath
            ) as? BetCell else {
                fatalError("Bet cell xib file does not exist.")
            }
            cell.configure(withVM: rowVM)
            return cell
        }
    }
    
    func updateTableView() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, BetCellViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.getCellVMsForTable())
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}


// MARK:- TableView Delegate
extension FriendDetailViewController: UITableViewDelegate {
    func configureTableView() {
        tableView.delegate = self
        tableView.register(UINib(nibName: K.cells.betCell, bundle: nil), forCellReuseIdentifier: K.cells.betCell)
        tableView.rowHeight = BetCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let betID = viewModel.getCellVM(at: indexPath).bet.betID {
            coordinator?.openBetDetail(withBetID: betID)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK:- ScrollView Delegate
extension FriendDetailViewController: UIScrollViewDelegate {
    // From https://anasimtiaz.com/2015/03/16/update-uitableview-when-user-scrolls-to-end-swift/
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Fetch once scrolled to bottom of tableView if the view model is not in the middle of another fetch.
        if !viewModel.isLoading && (maximumOffset - contentOffset <= scrollViewThreshold) {
            viewModel.loadAdditionalPastBets()
        }
    }
}
