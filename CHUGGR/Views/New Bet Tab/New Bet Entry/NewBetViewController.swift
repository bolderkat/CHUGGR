//
//  NewBetViewController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/25/20.
//

import UIKit

class NewBetViewController: UIViewController, Storyboarded {

    weak var coordinator: ChildCoordinating?
    var dataSource: UITableViewDiffableDataSource<Section, BetEntryCellViewModel>!
    private lazy var viewModel: NewBetViewModel = {
        return NewBetViewModel()
    }()
    
    @IBOutlet weak var topControl: UISegmentedControl!
    @IBOutlet weak var entryTable: UITableView!
    @IBOutlet weak var bottomControl: UISegmentedControl!
    @IBOutlet weak var sendBetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboard() // sets up keyboard dismissal on touch outside from extension
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
        
        updateButtonStatus()
        sendBetButton.layer.cornerRadius = 15
        
        entryTable.isScrollEnabled = false
        entryTable.allowsSelection = false

    }
    
    func initViewModel() {
        viewModel.createCellVMs()
        
        // Pass UI update functions to VM so view can reflect state in VM
        viewModel.reloadTableViewClosure = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.updateButtonStatus = { [weak self] in
            self?.updateButtonStatus()
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
        dataSource = UITableViewDiffableDataSource<Section, BetEntryCellViewModel>(
            tableView: entryTable,
            cellProvider: { tableView, indexPath, rowVM in
                
                // Custom cell setup for stake entry cell
                switch rowVM.type {
                case .stake:
                    guard let cell = tableView.dequeueReusableCell(
                            withIdentifier: K.cells.stakeCell,
                            for: indexPath) as? StakeEntryCell else {
                        fatalError("Cell does not exist in storyboard")
                    }
                    // Make sure entry fields are blank when cell is reused
                    cell.beerField.text = ""
                    cell.shotField.text = ""
                    cell.onStakeInput = self.viewModel.handle(beerStake:shotStake:)
                    return cell
                    
                case .dueDate, .gameday:
                    // Provide compact date picker in cell if iOS 14 or higher
                    if #available(iOS 14, *) {
                        guard let cell = tableView.dequeueReusableCell(
                                withIdentifier: K.cells.dateCell,
                                for: indexPath) as? DateEntryCell else {
                            fatalError("Cell does not exist in storyboard")
                        }

                        cell.titleLabel.text = rowVM.title
                        cell.datePicker.date = Date.init()
                        cell.onDateInput = self.viewModel.handle(date:)
                        return cell
                    } else {
                        fallthrough
                    }
                    
                default:
                    // All other cell types
                    guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: K.cells.betEntryCell,
                        for: indexPath
                    ) as? BetEntryCell else {
                        fatalError("Cell does not exist in storyboard")
                    }
                    cell.titleLabel.text = rowVM.title
                    
                    // Make sure textfields are empty when cell reused
                    cell.textField.placeholder = rowVM.placeholder ?? ""
                    cell.textField.text = ""
                    cell.rowType = rowVM.type
                    cell.onTextInput = self.viewModel.handle(text:for:)
                    cell.onDateInput = self.viewModel.handle(date:) // for iOS 13 and earlier
                    return cell
                }
            }
        )
    }
    
    func updateUI(animated: Bool = false) {
        // Set up table rows
        let rows = viewModel.cellViewModels
        var snapshot = NSDiffableDataSourceSnapshot<Section, BetEntryCellViewModel>()
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
    
    func updateButtonStatus() {
        sendBetButton.isEnabled = viewModel.isInputComplete
        sendBetButton.backgroundColor = sendBetButton.isEnabled ?
            UIColor(named: K.colors.orange) : UIColor(named: K.colors.gray3)
    }
}


// MARK:- Table View
extension NewBetViewController: UITableViewDelegate {
    func configureTableView() {
        entryTable.delegate = self
        entryTable.register(UINib(nibName: K.cells.betEntryCell, bundle: nil),
                            forCellReuseIdentifier: K.cells.betEntryCell)
        entryTable.register(UINib(nibName: K.cells.stakeCell, bundle: nil),
                            forCellReuseIdentifier: K.cells.stakeCell)
        entryTable.register(UINib(nibName: K.cells.dateCell, bundle: nil),
                            forCellReuseIdentifier: K.cells.dateCell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = viewModel.getCellViewModel(at: indexPath)
        if cell.type == .stat || cell.type == .event {
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
