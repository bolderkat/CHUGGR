//
//  AddFriendsViewController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/15/20.
//

import UIKit

class AddFriendViewController: UIViewController {
    
    weak var coordinator: FriendsCoordinator?
    let viewModel: AddFriendViewModel
    private var dataSource: UITableViewDiffableDataSource<Section, FriendCellViewModel>!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        initViewModel()
        configureDataSource()
        configureTableView()
    }
    
    init(
        viewModel: AddFriendViewModel,
        nibName: String? = nil,
        bundle: Bundle? = nil
    ) {
        self.viewModel = viewModel
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViewController() {
        title = "Add Friend"
        searchBar.delegate = self
        activityIndicator.isHidden = true
    }
    
    func initViewModel() {
        viewModel.initFetchAllUsers()
        
        viewModel.updateLoadingStatus = { [weak self] in
            DispatchQueue.main.async {
                self?.showLoadingStatus()
            }
        }
    }
    
    func showLoadingStatus() {
        if viewModel.isLoading {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            tableView.alpha = 0.0
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            tableView.alpha = 1.0
        }
    }
}

// MARK:- SearchBar delegate
extension AddFriendViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FriendCellViewModel>()
        snapshot.appendSections(Section.allCases)
        
        // Get cell VMs matching search criteria and apply to dataSource
        snapshot.appendItems(viewModel.provideCellVMs(forString: searchText))
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}


// MARK:- TableView diffable data source
extension AddFriendViewController {
    enum Section: CaseIterable {
        case main
    }
    
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, FriendCellViewModel>(
            tableView: tableView) { (tableView, indexPath, rowVM) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: K.cells.friendCell,
                for: indexPath
            ) as? FriendCell else {
                fatalError("Friend cell nib does not exist.")
            }
            cell.nameLabel.text = rowVM.fullName
            cell.userNameLabel.text = rowVM.userName
            return cell
        }
    }
    
}

// MARK:- TableView delegate
extension AddFriendViewController: UITableViewDelegate {
    func configureTableView() {
        tableView.delegate = self
        tableView.register(UINib(nibName: K.cells.friendCell, bundle: nil),
                           forCellReuseIdentifier: K.cells.friendCell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
