//
//  BetsViewController.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/6/20.
//

import UIKit

class BetsViewController: UIViewController {

    weak var coordinator: BetsCoordinator?
    private var dataSource: BetsTableDataSource!
    private let viewModel: BetsViewModel
    private let scrollViewThreshold: CGFloat = 100.0 // threshold at which fetching additional bets triggered
    
    
    @IBOutlet weak var betsTable: UITableView!
    @IBOutlet weak var pendingBetsView: UIView!
    @IBOutlet weak var pendingBetsLabel: UILabel!
    @IBOutlet weak var pendingStakeLabel: UILabel!

   let sampleData = SampleData()
    
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
    }
    
    func setUpViewController() {
        title = "Bets"
        
//        navigationController?.navigationBar.barTintColor = UIColor(named: K.colors.orange)
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.titleTextAttributes = [
//            NSAttributedString.Key.foregroundColor: UIColor.white,
//            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .semibold)
//        ]
    }
    
    func initViewModel() {
        viewModel.initFetchBets()
        
        viewModel.updatePendingBetsLabel = { [weak self] in
            DispatchQueue.main.async {
                self?.updateBetsPendingLabel()
            }
        }
        
        viewModel.reloadTableViewClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.updateTableView()
            }
        }
        
    }
    
    func updateTableView(animated: Bool = false) {
        // Set up table rows
        let involvedBets = viewModel.userInvolvedBetCellVMs
        let otherBets = viewModel.otherBetCellVMs
        
        // Load up snapshot with relevant data
        var snapshot = NSDiffableDataSourceSnapshot<Section, BetCellViewModel>()
        snapshot.appendSections([.myBets, .otherBets])
        snapshot.appendItems(involvedBets, toSection: .myBets)
        snapshot.appendItems(otherBets, toSection: .otherBets)
 
        
        dataSource.apply(snapshot, animatingDifferences: animated) // apply to tableView data source
    }
    
    func updateBetsPendingLabel() {
//        if viewModel.pendingBets.isEmpty {
//            pendingBetsView.isHidden = true
//        } else {
//            pendingBetsView.isHidden = false
            pendingBetsLabel.text = "\(viewModel.pendingBets.count) New Bets Pending!"
            pendingStakeLabel.text = viewModel.getPendingBetsLabel()
//        }
    }
    
}


// MARK:- TableView data source
extension BetsViewController {
    enum Section: Int {
        case myBets
        case otherBets
        
        var header: String {
            switch self {
            case .myBets:
                return "My Bets"
            case .otherBets:
                return "Other Bets"
            }
        }
    }
    
    
    func configureDataSource() {
        dataSource = BetsTableDataSource(
            tableView: betsTable, cellProvider: { (tableView, indexPath, rowVM) -> UITableViewCell? in
                // Set up cells for each bet
                guard let cell = tableView.dequeueReusableCell(withIdentifier: K.cells.betCell, for: indexPath) as? BetCell else {
                    fatalError("Bet dashboard cell nib does not exist")
                }
                cell.userNamesLabel.text = rowVM.getBothSideNames() // TODO: display proper side names
                cell.titleLabel.text = rowVM.bet.title
                cell.stakeLabel.text = rowVM.getStakeString()
                cell.resultLabel.text = rowVM.getBetStatus()
                return cell
            })
    }
    
    
}

// MARK: - TableView delegate
extension BetsViewController: UITableViewDelegate {
    
    func configureTableView() {
        betsTable.delegate = self
        betsTable.register(UINib(nibName: K.cells.betCell, bundle: nil),
                           forCellReuseIdentifier: K.cells.betCell)
        betsTable.rowHeight = 55.0

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
