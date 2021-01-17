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
        dismissKeyboard() // set up keyboard dismissal on tap
        setUpViewController()
        initViewModel()
        configureDataSource()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.createCellVMs()
        updateTableView(forString: searchBar.text)
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
        title = "Follow New User"
        searchBar.delegate = self
        activityIndicator.isHidden = true
    }
    
    func initViewModel() {
        viewModel.initSetUpAllUserListener()
        
        viewModel.didUpdateUserVMs = { [weak self] in
            DispatchQueue.main.async {
                self?.updateTableView(forString: "")
            }
        }
        
        viewModel.didChangeloadingStatus = { [weak self] in
            DispatchQueue.main.async {
                self?.showLoadingStatus()
            }
        }
        
        viewModel.onFriendFetch = { [weak self] friend in
            self?.onFriendFetch(friend)
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
    
    func updateTableView(forString searchString: String?) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FriendCellViewModel>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(viewModel.provideCellVMs(forString: searchString ?? ""))
        dataSource.apply(snapshot,animatingDifferences: false)
    }
    
    func onFriendFetch(_ friend: FullFriend) {
        // Passed to getFriend completion handler to provide fresh data when pushing friend detail
        coordinator?.showFriendDetail(for: friend)
    }
    
}

// MARK:- SearchBar delegate
extension AddFriendViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateTableView(forString: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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
            cell.configure(withVM: rowVM)
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
        let friend = viewModel.provideSelectedFriend(at: indexPath)
        viewModel.getFreshData(for: friend)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK:- ScrollView Delegate
extension AddFriendViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}
