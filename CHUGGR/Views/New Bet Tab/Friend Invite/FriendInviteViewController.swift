//
//  FriendInviteViewController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/17/20.
//

import UIKit

class FriendInviteViewController: UIViewController {
    weak var coordinator: ChildCoordinating?
    private let viewModel: FriendInviteViewModel
    private var dataSource: UITableViewDiffableDataSource<Section, InviteCellViewModel>!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Update friends from stored array when view appears
        viewModel.fetchFriends()
    }
    
    func configureViewController() {
        title = "New Bet"
        searchBar.delegate = self
    }

    func initViewModel() {
        viewModel.fetchFriends()
        viewModel.updateTableViewClosure = { [weak self] in
            self?.updateTableView()
        }

    }
    
    func updateTableView() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, InviteCellViewModel>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(viewModel.cellVMs, toSection: .friends)
        dataSource.apply(snapshot,animatingDifferences: false)
    }
}

// MARK:- TableView Data Source
extension FriendInviteViewController {
    enum Section: CaseIterable {
        case recents
        case friends
    }
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, InviteCellViewModel>(tableView: tableView)
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK:- SearchBar Delegate
extension FriendInviteViewController: UISearchBarDelegate {
}
