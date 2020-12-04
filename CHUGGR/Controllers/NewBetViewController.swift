//
//  NewBetViewController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/25/20.
//

import UIKit

class NewBetViewController: UIViewController, Storyboarded {

    weak var coordinator: ChildCoordinating?
    var dataSource: UITableViewDiffableDataSource<Section, BetEntryRowViewModel>!
    private lazy var viewModel: NewBetViewModel = {
        return NewBetViewModel()
    }()
    
    @IBOutlet weak var topControl: UISegmentedControl!
    @IBOutlet weak var entryTable: UITableView!
    @IBOutlet weak var bottomControl: UISegmentedControl!
    @IBOutlet weak var sendBetButton: UIButton!
    
    var rows = [BetEntryRowViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        initViewModel()
        configureTableView()
        configureDataSource()
        updateUI()
        
    }
    
    func setUpViewController() {
        title = "New Bet" // TODO: update dynamically based on selected friend
        navigationController?.navigationBar.barTintColor = UIColor(named: K.colors.orange)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        sendBetButton.layer.cornerRadius = 15
    }
    
    func initViewModel() {
        viewModel.createCellVMs()
        
        // Naive binding
        viewModel.reloadTableViewClosure = { [weak self] in
            self?.updateUI()
        }
    }
    
    @IBAction func topControlChanged(_ sender: UISegmentedControl) {
        viewModel.changeBetType(sender.selectedSegmentIndex)
    }

    
    @IBAction func bottomControlChanged(_ sender: UISegmentedControl) {
        viewModel.changeSide(sender.selectedSegmentIndex)
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        viewModel.createNewBet()
    }
    
}

// MARK:- Data Source
extension NewBetViewController {
    enum Section {
        case main
    }

    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, BetEntryRowViewModel>(
            tableView: entryTable,
            cellProvider: { tableView, indexPath, rowVM in
                // Custom cell setup for stake entry cell
                if rowVM.type == .stake {
                    return tableView.dequeueReusableCell(withIdentifier: K.cells.stakeCell,
                                                             for: indexPath) as? StakeEntryCell
                } else {
                    // All other cell types
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: K.cells.betEntryCell,
                                                                   for: indexPath) as? BetEntryCell else {
                        fatalError("Cell does not exist in storyboard")
                    }
                    cell.titleLabel.text = rowVM.title
                    cell.textField.placeholder = rowVM.placeholder ?? ""
                    cell.rowType = rowVM.type
                    return cell
                }
            }
        )
    }
    
    func updateUI(animated: Bool = false) {
        // Set up table rows
        rows = viewModel.cellViewModels
        var snapshot = NSDiffableDataSourceSnapshot<Section, BetEntryRowViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(rows)
        dataSource.apply(snapshot, animatingDifferences: animated, completion: nil)
        
        // Set up bottom seg. control labels
        var leftLabel = ""
        var rightLabel = ""
        switch viewModel.selectedBetType {
        case .spread:
            leftLabel = "Over"
            rightLabel = "Under"
        case .moneyline:
            leftLabel = "Team 1"
            rightLabel = "Team 2"
        case .event:
            leftLabel = "For"
            rightLabel = "Against"
        }
        bottomControl.setTitle(leftLabel, forSegmentAt: 0)
        bottomControl.setTitle(rightLabel, forSegmentAt: 1)
    }
}


// MARK:- Table View
extension NewBetViewController: UITableViewDelegate {
    func configureTableView() {
        entryTable.delegate = self
        entryTable.register(UINib(nibName: K.cells.betEntryCell, bundle: nil), forCellReuseIdentifier: K.cells.betEntryCell)
        entryTable.register(UINib(nibName: K.cells.stakeCell, bundle: nil), forCellReuseIdentifier: K.cells.stakeCell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if rows[indexPath.row].type == .stat || rows[indexPath.row].type == .event {
            return 70
        }
        else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK:- Text Field Delegate
extension NewBetViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        textField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
    }
}
