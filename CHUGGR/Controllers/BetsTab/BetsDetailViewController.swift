//
//  BetsDetailViewController.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/10/20.
//

import UIKit

class BetsDetailViewController: UIViewController, Storyboarded {

    weak var coordinator: ChildCoordinating?
    let sampleData = SampleData()
    var selectedBet: SampleBet?
    var messages: [Message] = []

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var betTypeLabel: UILabel!
    @IBOutlet weak var leftLabel1: UILabel!
    @IBOutlet weak var rightLabel1: UILabel!
    @IBOutlet weak var leftLabel2: UILabel!
    @IBOutlet weak var rightLabel2: UILabel!
    @IBOutlet weak var leftLabel3: UILabel!
    @IBOutlet weak var rightLabel3: UILabel!
    @IBOutlet weak var leftLabel4: UILabel!
    @IBOutlet weak var rightLabel4: UILabel!
    @IBOutlet weak var leftLabel5: UILabel!
    @IBOutlet weak var rightLabel5: UILabel!
    @IBOutlet weak var leftLabel6: UILabel!
    @IBOutlet weak var rightLabel6: UILabel!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var betCard: UIView!
    @IBOutlet weak var closeBetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bet Details"
        betCard.layer.cornerRadius = 30
        closeBetButton.layer.cornerRadius = 15
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(UINib(nibName: K.cells.messageCell, bundle: nil),
                                  forCellReuseIdentifier: K.cells.messageCell)
        
        
        
//        messageTableView.rowHeight = UITableView.automaticDimension
//        
//        messageTableView.estimatedRowHeight = 200

        // scroll to bottom of table, to put in message load/sort function later
//        let indexPath = IndexPath(row: messages.count - 1, section: 0)
//        messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        titleLabel.text = selectedBet?.betDescription
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
    }
    
    func setUpBetCard(for betType: BetType) {
        // switch on betType to set up view
    }

}

extension BetsDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTableView.dequeueReusableCell(withIdentifier: K.cells.messageCell) as! MessageCell
        cell.message = messages[indexPath.row]

//      will hide sender field if single recipient. also will hide if consecutive msgs from same sender in group chat
//        var message = messages[indexPath.row]
//        if message.sender == "dm@dm.com" {
//            message.sender = nil
//        }
        return cell
    }
}
