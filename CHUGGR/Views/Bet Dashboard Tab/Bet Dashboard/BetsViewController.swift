//
//  BetsViewController.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/6/20.
//

import UIKit

class BetsViewController: UIViewController {

    weak var coordinator: BetsCoordinator?
    private var dataSource: UITableViewDiffableDataSource<Section, BetCellViewModel>!
    private let viewModel: BetsViewModel
    private let refreshControl = UIRefreshControl() // for table view refresh
    
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
        
        navigationController?.navigationBar.barTintColor = UIColor(named: K.colors.orange)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
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
        
        viewModel.endRefreshControl = { [weak self] in
            DispatchQueue.main.async {
                self?.endRefreshControl()
            }
        }
        
    }
    
    func updateTableView(animated: Bool = false) {
        // Set up table rows
        let involvedBets = viewModel.userInvolvedBetCellVMs
        let otherBets = viewModel.otherBetCellVMs
        
        // Load up snapshot with relevant data
        var snapshot = NSDiffableDataSourceSnapshot<Section, BetCellViewModel>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(involvedBets, toSection: .myBets)
        snapshot.appendItems(otherBets, toSection: .otherBets)
        
        dataSource.apply(snapshot, animatingDifferences: animated) // apply to tableView data source
    }
    
    func updateBetsPendingLabel() {
//        if viewModel.pendingBets.isEmpty {
//            pendingBetsView.removeFromSuperview()
//        } else {
//            view.addSubview(pendingBetsView)
            pendingBetsLabel.text = "\(viewModel.pendingBets.count) New Bets Pending!"
            pendingStakeLabel.text = viewModel.getPendingBetsLabel()
//        }
    }
    
    @objc func refreshBets() {
        viewModel.refreshBets()
    }
    
    func endRefreshControl() {
        refreshControl.endRefreshing()
    }
    
    
}


// MARK:- Table view data source
private extension BetsViewController {
    enum Section: CaseIterable {
        case myBets
        case otherBets
    }
    
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, BetCellViewModel>(
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

// MARK: - Table view delegate
extension BetsViewController: UITableViewDelegate {
    
    func configureTableView() {
        betsTable.delegate = self
        betsTable.register(UINib(nibName: K.cells.betCell, bundle: nil),
                           forCellReuseIdentifier: K.cells.betCell)
        betsTable.rowHeight = 55.0
        refreshControl.addTarget(self, action: #selector(refreshBets), for: .valueChanged)
        betsTable.refreshControl = refreshControl
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        coordinator?.openBetDetail(for: tableSections[indexPath.section].cells[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
