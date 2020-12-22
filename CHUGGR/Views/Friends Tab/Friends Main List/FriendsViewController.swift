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
    private var dataSource: UITableViewDiffableDataSource<Section, FriendCellViewModel>!
    @IBOutlet weak var placeholderLabel: UITableView!
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
        dismissKeyboard() // set up keyboard dismissal on tap
        setUpViewController()
        initViewModel()
        configureDataSource()
        configureTableView()
        showPlaceholderIfEmpty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Update friends from stored array when view appears
        viewModel.fetchFriends()
    }
    
    func setUpViewController() {
        title = "Following"
        
        searchBar.delegate = self
        let addFriendButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addFriendPressed)
        )
        navigationItem.rightBarButtonItem = addFriendButtonItem
    }
    
    func initViewModel() {
        viewModel.fetchFriends()
        viewModel.updateTableViewClosure = { [weak self] in
            self?.updateTableView()
        }
        
        viewModel.onFriendLoad = { [weak self] friend in
            DispatchQueue.main.async {
                self?.onFriendLoad(friend)
            }
        }
    }
    
    func showPlaceholderIfEmpty() {
        if viewModel.cellVMs.isEmpty {
            placeholderLabel.isHidden = false
            tableView.isHidden = true
            return
        } else {
            placeholderLabel.isHidden = true
            tableView.isHidden = false
        }
    }
    
    func updateTableView() {
        showPlaceholderIfEmpty()
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, FriendCellViewModel>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(viewModel.cellVMs)
        dataSource.apply(snapshot,animatingDifferences: false)
    }
    
    func onFriendLoad(_ friend: FullFriend) {
        coordinator?.showFriendDetail(for: friend)
    }
    
    @objc func addFriendPressed() {
        coordinator?.addFriend()
    }

}

// MARK:- TableView Data source
extension FriendsViewController {
    enum Section: CaseIterable {
        case main
    }
    
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, FriendCellViewModel>(tableView: tableView) { (tableView, indexPath, rowVM) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: K.cells.friendCell,
                    for: indexPath
            ) as? FriendCell else {
                fatalError("Friend cell nib does not exist.")
            }
            cell.configure(withVM: rowVM)
            return cell
        }
    }
    
}

// MARK:- TableView Delegate
extension FriendsViewController: UITableViewDelegate {
    func configureTableView() {
        tableView.delegate = self
        tableView.register(UINib(nibName: K.cells.friendCell, bundle: nil),
                           forCellReuseIdentifier: K.cells.friendCell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let uid = viewModel.getFriendUID(at: indexPath)
        viewModel.getFriend(withUID: uid)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK:- ScrollView Delegate
extension FriendsViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}

// MARK:- SearchBar Delegate
extension FriendsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FriendCellViewModel>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(viewModel.provideCellVMs(forString: searchText))
        dataSource.apply(snapshot)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
