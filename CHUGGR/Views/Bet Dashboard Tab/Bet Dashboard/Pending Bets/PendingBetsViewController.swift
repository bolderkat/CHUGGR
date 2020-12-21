//
//  PendingBetsViewController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/20/20.
//

import UIKit

class PendingBetsViewController: UIViewController {
    weak var coordinator: BetsCoordinator?
    private let viewModel: PendingBetsViewModel
    private var dataSource: UITableViewDiffableDataSource<Section, BetCellViewModel>!
    
    @IBOutlet weak var tableView: UITableView!
    
    init(
        viewModel: PendingBetsViewModel,
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchPendingBets()
    }
    
    func setUpViewController() {
        title = "Pending Bets"
    }
    
    func initViewModel() {
        viewModel.reloadTableView = { [weak self] in
            self?.reloadTableView()
        }
        
        viewModel.fetchPendingBets()
    }
    
    func reloadTableView(animated: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, BetCellViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.betCellVMs, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

}


// MARK:- Table View Data Source
extension PendingBetsViewController {
    enum Section {
        case main
    }
    
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, BetCellViewModel>(tableView: tableView) { (tableView, indexPath, rowVM) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.cells.betCell, for: indexPath) as? BetCell else {
                fatalError("Bet cell nib not found.")
            }
            cell.configure(withVM: rowVM)
            return cell
        }
    }
}


// MARK:- TableView delegate
extension PendingBetsViewController: UITableViewDelegate {
    func configureTableView() {
        tableView.delegate = self
        tableView.register(UINib(nibName: K.cells.betCell, bundle: nil), forCellReuseIdentifier: K.cells.betCell)
        tableView.rowHeight = 55.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let betID = viewModel.getCellVM(at: indexPath).bet.betID {
            coordinator?.openBetDetail(withBetID: betID, userInvolvement: .invited)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
