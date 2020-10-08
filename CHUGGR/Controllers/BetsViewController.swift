//
//  BetsViewController.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/6/20.
//

import UIKit

class BetsViewController: UIViewController {

    @IBOutlet weak var betsTable: UITableView!
    @IBOutlet weak var pendingBetsLabel: UILabel!
    @IBOutlet weak var pendingCurrencyLabel: UILabel!

    // MARK:- data for testing
    let pending = ["3 New Bets Pending!", "4 🍺"]
    let bets: [Bet] = [
        Bet(name: "David", betDescription: "OVER Alex Caruso points: 6", currency: "1 🍺", result: "IN PLAY"),
        Bet(name: "Torrance", betDescription: "Packers LOSE vs Seahawks", currency: "2 🍺", result: "WON")
    ]

    let otherBets: [Bet] = [
        Bet(name: "Derek vs. Micekey", betDescription: "Packers LOSE vs Seahawks", currency: "1 🍺", result: "DEREK WON"),
        Bet(name: "2 people vs. 2 people", betDescription: "A's win ALCS", currency: "1 🍺 1 🥃", result: "IN PLAY"),
        Bet(name: "Torrance", betDescription: "UCLA gets accredited", currency: "6 🍺 9 🥃", result: "LOST"),
        Bet(name: "Cheung vs. Linkous", betDescription: "EPL plays full season", currency: "1 🍺 1 🥃", result: "IN PLAY")
    ]

    var tableSections: [BetsTableSection] { [
        BetsTableSection(title: "My Bets", cells: bets),
        BetsTableSection(title: "Other Bets", cells: otherBets)
    ]
    }



    // MARK:- begin real stuff

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bets"
        betsTable.dataSource = self
        betsTable.delegate = self
        betsTable.register(UINib(nibName: K.identifiers.betCell, bundle: nil),
                           forCellReuseIdentifier: K.identifiers.betCell)
        betsTable.rowHeight = 55.0

        pendingBetsLabel.text = pending[0]
        pendingCurrencyLabel.text = pending[1]

        navigationController?.navigationBar.barTintColor = UIColor(named: K.colors.orange)
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
    }





    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
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
        let cell = tableView.dequeueReusableCell(withIdentifier: K.identifiers.betCell, for: indexPath) as! BetCell
        cell.bet = tableSections[indexPath.section].cells[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
