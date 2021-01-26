//
//  BetsViewController.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/6/20.
//

import UIKit
import UserNotifications

class BetsViewController: UIViewController {

    weak var coordinator: BetsCoordinator?
    private var dataSource: BetsTableDataSource!
    private let viewModel: BetsViewModel
    private let scrollViewThreshold: CGFloat = 100.0 // threshold at which fetching additional bets triggered
    
    
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var betsTable: UITableView!
    @IBOutlet weak var pendingBetsView: UIView!
    @IBOutlet weak var pendingBetsLabel: UILabel!
    @IBOutlet weak var pendingStakeLabel: UILabel!
    @IBOutlet weak var pendingBetsButton: UIButton!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    
    init(
        viewModel: BetsViewModel,
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
        configureDataSource()
        initViewModel()
        configureTableView()
        showPlaceholderIfEmpty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.sortPendingAndInvolvedBets()
        viewModel.initFetchOtherBets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Get user permission for push notifications
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    func setUpViewController() {
        title = "Bets"
    }
    
    func initViewModel() {
        viewModel.initFetchBets()
        
        viewModel.didUpdatePendingBets = { [weak self] in
            DispatchQueue.main.async {
                self?.showPlaceholderIfEmpty()
                self?.updateBetsPendingLabel()
            }
        }
        
        viewModel.didUpdateBetCellVMs = { [weak self] in
            DispatchQueue.main.async {
                self?.updateTableView()
            }
        }
        
    }
    func showPlaceholderIfEmpty() {
        if viewModel.userInvolvedBetCellVMs.isEmpty, viewModel.otherBetCellVMs.isEmpty, viewModel.pendingBets.isEmpty {
            placeholderLabel.isHidden = false
            pendingBetsView.isHidden = true
            betsTable.isHidden = true
        } else {
            placeholderLabel.isHidden = true
            betsTable.isHidden = false
        }
    }
    
    func updateTableView(animated: Bool = false) {
        // Set up table rows
        let involvedBets = viewModel.userInvolvedBetCellVMs
        let otherBets = viewModel.otherBetCellVMs
        
        showPlaceholderIfEmpty()

        // Load up snapshot with relevant data
        var snapshot = NSDiffableDataSourceSnapshot<Section, BetCellViewModel>()
        if involvedBets.isEmpty && otherBets.isEmpty {
            return
        }
        if involvedBets.isEmpty {
            snapshot.appendSections([.otherBets])
            snapshot.appendItems(otherBets, toSection: .otherBets)
        } else if otherBets.isEmpty {
            snapshot.appendSections([.myActiveBets])
            snapshot.appendItems(involvedBets, toSection: .myActiveBets)
        } else {
            snapshot.appendSections([.myActiveBets, .otherBets])
            snapshot.appendItems(involvedBets, toSection: .myActiveBets)
            snapshot.appendItems(otherBets, toSection: .otherBets)
        }

        dataSource.apply(snapshot, animatingDifferences: animated) // apply to tableView data source
    }
    
    func updateBetsPendingLabel() {
        if viewModel.pendingBets.isEmpty {
            pendingBetsView.isHidden = true
            pendingBetsButton.isEnabled = false
            tableViewTopConstraint.constant = -pendingBetsView.frame.height // extend table view to safe area to hide pending header
        } else {
            betsTable.isHidden = false
            pendingBetsView.isHidden = false
            pendingBetsButton.isEnabled = true
            pendingBetsLabel.text = viewModel.getPendingBetsLabel()
            pendingStakeLabel.text = viewModel.getPendingBetsStake()
            tableViewTopConstraint.constant = 0
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func pendingBetsViewPressed(_ sender: UIButton) {
        coordinator?.openPendingBets()
    }
    
}


// MARK:- TableView data source
extension BetsViewController {
    enum Section: Int {
        case myActiveBets
        case otherBets
        
        var header: String {
            switch self {
            case .myActiveBets:
                return "My Active Bets"
            case .otherBets:
                return "Other Bets"
            }
        }
    }
    
    
    func configureDataSource() {
        dataSource = BetsTableDataSource(
            tableView: betsTable) { (tableView, indexPath, rowVM) -> UITableViewCell? in
                // Set up cells for each bet
                guard let cell = tableView.dequeueReusableCell(withIdentifier: K.cells.betCell, for: indexPath) as? BetCell else {
                    fatalError("Bet dashboard cell nib does not exist")
                }
                cell.configure(withVM: rowVM)
                return cell
            }
    }
    
    
}

// MARK: - TableView delegate
extension BetsViewController: UITableViewDelegate {
    
    func configureTableView() {
        betsTable.delegate = self
        betsTable.register(UINib(nibName: K.cells.betCell, bundle: nil),
                           forCellReuseIdentifier: K.cells.betCell)
        betsTable.rowHeight = 110.0

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let betID = viewModel.getCellVM(at: indexPath).bet.betID {
            coordinator?.openBetDetail(withBetID: betID)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK:- ScrollView Delegate
extension BetsViewController: UIScrollViewDelegate {
    // From https://anasimtiaz.com/2015/03/16/update-uitableview-when-user-scrolls-to-end-swift/
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Fetch once scrolled to bottom of tableView if the view model is not in the middle of another fetch.
        if !viewModel.isLoading && (maximumOffset - contentOffset <= scrollViewThreshold) {
            viewModel.loadAdditionalBets()
        }
    }
}
