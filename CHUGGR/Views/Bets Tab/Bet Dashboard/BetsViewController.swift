//
//  BetsViewController.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/6/20.
//

import UIKit

class BetsViewController: UIViewController, Storyboarded {

    weak var coordinator: BetsCoordinator?
    @IBOutlet weak var betsTable: UITableView!
    @IBOutlet weak var pendingBetsLabel: UILabel!
    @IBOutlet weak var pendingCurrencyLabel: UILabel!

   let sampleData = SampleData()
    
    var tableSections: [BetsTableSection] { [
        BetsTableSection(title: "My Bets", cells: sampleData.bets),
        BetsTableSection(title: "Other Bets", cells: sampleData.otherBets)
    ]
    }



    // MARK:- begin real stuff

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bets"
        betsTable.dataSource = self
        betsTable.delegate = self
        betsTable.register(UINib(nibName: K.cells.betCell, bundle: nil),
                           forCellReuseIdentifier: K.cells.betCell)
        betsTable.rowHeight = 55.0

        pendingBetsLabel.text = sampleData.pending[0]
        pendingCurrencyLabel.text = sampleData.pending[1]

        navigationController?.navigationBar.barTintColor = UIColor(named: K.colors.orange)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]

    }
}


// MARK: - Table view delegate and data source
extension BetsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSections[section].cells.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cells.betCell, for: indexPath) as! BetCell
        cell.bet = tableSections[indexPath.section].cells[indexPath.row]
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.openBetDetail(for: tableSections[indexPath.section].cells[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
