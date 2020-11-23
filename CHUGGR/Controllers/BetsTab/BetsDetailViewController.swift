//
//  BetsDetailViewController.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/10/20.
//

import UIKit

class BetsDetailViewController: UIViewController {

    let sampleData = SampleData()
    var selectedBet: SampleBet?
    var messages: [Message] {
        sampleData.messages
    }

    @IBOutlet weak var betDescription: UILabel!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
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
        betDescription.text = selectedBet?.betDescription
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
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
