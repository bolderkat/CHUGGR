//
//  FriendInviteViewController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/17/20.
//

import UIKit

class FriendInviteViewController: UIViewController {
    weak var coordinator: NewBetsCoordinator?
    private let viewModel: FriendInviteViewModel
    private var dataSource: FriendInviteDataSource!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var recipientViewBottomConstraint: NSLayoutConstraint!
    
    init(
        viewModel: FriendInviteViewModel,
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
        configureDataSource()
        configureTableView()
        updateRecipientView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpKeyboardNotifications()
        // Update friends from stored array when view appears
        viewModel.fetchFriends()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
    }
    
    func configureViewController() {
        title = "New Bet"
        searchBar.delegate = self
    }

    func initViewModel() {
        viewModel.fetchFriends()
        viewModel.updateTableViewClosure = { [weak self] string in
            self?.updateTableView(withString: string)
        }
        viewModel.updateRecipientView = { [weak self] in
            self?.updateRecipientView()
        }

    }
    
    func setUpKeyboardNotifications() {
        // Adapted from https://stackoverflow.com/a/50325088
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardNotification),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardNotification),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func handleKeyboardNotification(_ notification: Notification) {
        // Adapted from https://stackoverflow.com/a/50325088
        if let userInfo = notification.userInfo {
            let key = UIResponder.keyboardFrameEndUserInfoKey
            guard let keyboardFrame = (userInfo[key] as AnyObject).cgRectValue else { return }
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            // Set recipient view bottom constraint based on keyboard presence
            if isKeyboardShowing {
                recipientViewBottomConstraint.constant = -keyboardFrame.height + (tabBarController?.tabBar.frame.size.height ?? 0)
                
            } else {
                recipientViewBottomConstraint.constant = 0
            }
            
            UIView.animate(withDuration: 0.35) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func updateTableView(withString searchString: String) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, InviteCellViewModel>()
        snapshot.appendSections([.friends]) // TODO: Add recents once implemented
        snapshot.appendItems(viewModel.provideCellVMs(forString: searchString), toSection: .friends)
        dataSource.apply(snapshot,animatingDifferences: false)
    }
    
    func updateRecipientView() {
        recipientLabel.text = viewModel.getRecipientNames()
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        // If no selected friends, have user confirm that they want to create a house bet
        if viewModel.selectedFriends.isEmpty {
            let alert = UIAlertController(
                title: "House Bet",
                message: "Create a house bet with yourself as the only involved user?",
                preferredStyle: .actionSheet)
            
            alert.addAction(
                UIAlertAction(
                    title: "Continue",
                    style: .default,
                    handler: { action in
                        self.goToBetEntry()
                    }
                )
            )
            
            alert.addAction(
                UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: nil
                )
            )
            
            present(alert, animated: true, completion: nil)
        } else {
            goToBetEntry()
        }
    }
    
    func goToBetEntry() {
        coordinator?.goToBetEntry(inviting: viewModel.selectedFriends)
    }
    
}

// MARK:- TableView Data Source
extension FriendInviteViewController {
    enum Section: Int {
        case recents
        case friends
        
        var header: String {
            switch self {
            case .recents:
                return "Recents"
            case .friends:
                return "Friends"
            }
        }
    }
    func configureDataSource() {
        dataSource = FriendInviteDataSource(tableView: tableView)
        { (tableView, indexPath, rowVM) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: K.cells.inviteCell,
                    for: indexPath
            ) as? InviteCell else {
                fatalError("Invite cell nib does not exist.")
            }
            cell.viewModel = rowVM
            cell.configure()
            return cell
        }
    }
    
}


// MARK:- TableView Delegate
extension FriendInviteViewController: UITableViewDelegate {
    func configureTableView() {
        tableView.delegate = self
        tableView.register(UINib(nibName: K.cells.inviteCell, bundle: nil),
                           forCellReuseIdentifier: K.cells.inviteCell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectUser(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK:- ScrollView Delegate
extension FriendInviteViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}


// MARK:- SearchBar Delegate
extension FriendInviteViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateTableView(withString: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
