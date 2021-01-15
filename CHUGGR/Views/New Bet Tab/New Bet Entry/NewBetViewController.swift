//
//  NewBetViewController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/25/20.
//

import UIKit

class NewBetViewController: UIViewController {

    weak var coordinator: ChildCoordinating?
    private var dataSource: UITableViewDiffableDataSource<Section, BetEntryCellViewModel>!
    private let viewModel: NewBetViewModel
    
    @IBOutlet weak var topControl: UISegmentedControl!
    @IBOutlet weak var entryTable: UITableView!
    @IBOutlet weak var bottomControl: UISegmentedControl!
    @IBOutlet weak var sendBetButton: UIButton!
    
    init(
        viewModel: NewBetViewModel,
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
        dismissKeyboard() // sets up keyboard dismissal on touch outside from extension
        configureDataSource()
        initViewModel()
        setUpViewController()
        configureTableView()
        
    }
    
    func setUpViewController() {
        title = viewModel.getVCTitle()
        updateButtonStatus(isInputValid: false)
        sendBetButton.layer.cornerRadius = 15
    }
    
    
    func initViewModel() {        
        // Pass UI update functions to VM so view can reflect state in VM
        viewModel.didUpdateCellVMs = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.didValidateInput = { [weak self] isInputValid in
            self?.updateButtonStatus(isInputValid: isInputValid)
        }
        viewModel.createCellVMs()
    }
    
    @IBAction func topControlChanged(_ sender: UISegmentedControl) {
        viewModel.changeBetType(sender.selectedSegmentIndex)
    }

    
    @IBAction func bottomControlChanged(_ sender: UISegmentedControl) {
        viewModel.changeSide(sender.selectedSegmentIndex)
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let id = viewModel.createNewBet() else { return }
        coordinator?.openBetDetail(withBetID: id, userInvolvement: .accepted)
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
    
    func updateButtonStatus(isInputValid: Bool) {
        sendBetButton.isEnabled = isInputValid
        sendBetButton.backgroundColor = sendBetButton.isEnabled ?
            UIColor(named: K.colors.orange) : UIColor(named: K.colors.gray3)
    }

    
}

// MARK:- Table View Data Source
extension NewBetViewController {
    enum Section {
        case main
    }

    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, BetEntryCellViewModel>(
            tableView: entryTable,
            cellProvider: { tableView, indexPath, rowVM -> UITableViewCell? in
                
                // Custom cell setup for stake entry cell
                switch rowVM.type {
                case .stake:
                    guard let cell = tableView.dequeueReusableCell(
                            withIdentifier: K.cells.stakeCell,
                            for: indexPath) as? StakeEntryCell else {
                        fatalError("Bet stake entry cell nib does not exist")
                    }
                    // Make sure entry fields are blank when cell is reused
                    // TODO: pass these closures to cell via cell VM instead of directly from parent VM
                    cell.configure()
                    cell.onStakeInput = { [weak self] beers, shots in
                        self?.viewModel.handle(beerStake: beers, shotStake: shots)
                    }
                    return cell
                    
                case .dueDate, .gameday:
                    // Provide compact date picker in cell if iOS 14 or higher
                    if #available(iOS 14, *) {
                        guard let cell = tableView.dequeueReusableCell(
                                withIdentifier: K.cells.dateCell,
                                for: indexPath) as? DateEntryCell else {
                            fatalError("Bet date entry cell nib does not exist")
                        }

                        cell.configure(withVM: rowVM)
                        
                        cell.onDateInput = { [weak self] in
                            self?.viewModel.handle(date: $0)
                        }
                        return cell
                    } else {
                        fallthrough
                    }
                    
                case .event, .line, .stat, .team1, .team2:
                    // All other cell types
                    guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: K.cells.betEntryCell,
                        for: indexPath
                    ) as? BetEntryCell else {
                        fatalError("Bet entry cell nib does not exist")
                    }
                    
                    cell.configure(withVM: rowVM)
                    cell.onTextInput = { [weak self] (text, rowType) in
                        self?.viewModel.handle(text: text, for: rowType)
                    }
                    cell.onDateInput = { [weak self]  in
                        self?.viewModel.handle(date: $0) // for iOS 13 and earlier
                    }
                    return cell
                }
            }
        )
    }
    
}


// MARK:- Table View
extension NewBetViewController: UITableViewDelegate {
    func configureTableView() {
        entryTable.delegate = self
        entryTable.isScrollEnabled = false
        entryTable.allowsSelection = false
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
