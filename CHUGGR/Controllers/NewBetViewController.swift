//
//  NewBetViewController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/25/20.
//

import UIKit

class NewBetViewController: UIViewController, Storyboarded {

    weak var coordinator: ChildCoordinating?
    var dataSource: UITableViewDiffableDataSource<Section, EntryRow>!
    var viewModel = NewBetViewModel()
    
    @IBOutlet weak var topControl: UISegmentedControl!
    @IBOutlet weak var entryTable: UITableView!
    @IBOutlet weak var bottomControl: UISegmentedControl!
    @IBOutlet weak var sendBetButton: UIButton!
    
    var selectedBetType: BetType = .spread
    var selectedSide: Side = .one
    var rows = [EntryRow]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
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
    
    @IBAction func topControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedBetType = .spread
        case 1:
            selectedBetType = .moneyline
        case 2:
            selectedBetType = .event
        default:
            return
        }
        updateUI(for: selectedBetType)
    }
    
    @IBAction func bottomControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedSide = .one
        case 1:
            selectedSide = .two
        default:
            return
        }
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        
    }
    
}

// MARK:- Data Source
extension NewBetViewController {
    enum Section {
        case main
    }
    

    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, EntryRow>(
            tableView: entryTable,
            cellProvider: { tableView, indexPath, entryRow in
                if entryRow.title == "Stake" {
                    return tableView.dequeueReusableCell(withIdentifier: K.cells.stakeCell, for: indexPath) as! StakeEntryCell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: K.cells.betEntryCell, for: indexPath) as! BetEntryCell
                    cell.titleLabel.text = entryRow.title
                    cell.textField.placeholder = entryRow.placeholder ?? ""
                    return cell
                }
            }
        )
    }
    
    func updateUI(for betType: BetType = .spread, animated: Bool = false) {
        // Set up table rows
        rows = viewModel.getRowLabels(for: betType)
        var snapshot = NSDiffableDataSourceSnapshot<Section, EntryRow>()
        snapshot.appendSections([.main])
        snapshot.appendItems(rows)
        dataSource.apply(snapshot, animatingDifferences: animated, completion: nil)
        
        // Set up bottom seg. control labels
        var leftLabel = ""
        var rightLabel = ""
        switch betType {
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
        if rows[indexPath.row].title == "Stat" || rows[indexPath.row].title == "Event" {
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
