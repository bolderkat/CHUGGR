//
//  ProfileViewController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/11/20.
//

import UIKit

class ProfileViewController: UIViewController {
    
    weak var coordinator: ProfileCoordinator?
    private let viewModel: ProfileViewModel
    private var dataSource: ProfileTableDataSource!
    private let scrollViewThreshold: CGFloat = 100.0 // threshold at which fetching additional bets is triggered
    
    @IBOutlet weak var profPicView: UIImageView!
    @IBOutlet weak var drinksGivenLabel: UILabel!
    @IBOutlet weak var drinksReceivedLabel: UILabel!
    @IBOutlet weak var drinksOutstandingLabel: UILabel!
    @IBOutlet weak var friendsCountLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var realNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    init(viewModel: ProfileViewModel,
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
        // Refresh bets and update user data
        viewModel.initFetchPastBets()
        viewModel.bindUserToListener()
    }
    
    func configureViewController() {
        title = viewModel.user.userName
        tabBarItem.title = "Profile"
        self.navigationItem.rightBarButtonItem = .init(
            title: "Log Out",
            style: .plain,
            target: self,
            action: #selector(logOutPressed)
        )
        updateLabels()
    }
    
    func updateLabels() {
        // TODO: add user profile pic
        profPicView.image = UIImage(named: K.Images.profPicPlaceholder)
        drinksGivenLabel.text = viewModel.getDrinksString(forStat: .given)
        drinksReceivedLabel.text = viewModel.getDrinksString(forStat: .received)
        drinksOutstandingLabel.text = viewModel.getDrinksString(forStat: .outstanding)
        friendsCountLabel.text = String(viewModel.user.numFriends)
        userNameLabel.text = viewModel.user.userName
        realNameLabel.text = "\(viewModel.user.firstName) \(viewModel.user.lastName)"
        bioLabel.text = viewModel.user.bio
    }
    
    func initViewModel() {
        viewModel.updateVCLabels = { [weak self] in
            DispatchQueue.main.async {
                self?.updateLabels()
            }
        }
        
        viewModel.updateTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.updateTableView()
            }
        }
        viewModel.bindUserToListener()
    }
    

    @objc func logOutPressed() {
        viewModel.logOut()
        if let coordinator = coordinator, let mainCoordinator = coordinator.parentCoordinator {
            mainCoordinator.logOut()
        }
    }
    
}

// MARK:- TableView Data Source
extension ProfileViewController {
    enum Section {
        case main
        
        var header: String {
            switch self {
            case .main:
                return "Past Bets"
            }
        }
    }
    
    func configureDataSource() {
        dataSource = ProfileTableDataSource(
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
extension ProfileViewController: UITableViewDelegate {
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
extension ProfileViewController: UIScrollViewDelegate {
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
