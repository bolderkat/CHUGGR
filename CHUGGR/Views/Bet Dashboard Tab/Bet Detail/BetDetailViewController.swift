//
//  BetsDetailViewController.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/10/20.
//

import UIKit
import Firebase

class BetDetailViewController: UIViewController {

    weak var coordinator: ChildCoordinating?
    private let viewModel: BetDetailViewModel
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
    
    init(
        viewModel: BetDetailViewModel,
        nibName: String? = nil,
        bundle: Bundle? = nil
    ) {
        self.viewModel = viewModel
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // TODO: Show loading indicator while waiting for bet from DB!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        initViewModel()
        
//        messageTableView.rowHeight = UITableView.automaticDimension
//
//        messageTableView.estimatedRowHeight = 200

        // scroll to bottom of table, to put in message load/sort function later
//        let indexPath = IndexPath(row: messages.count - 1, section: 0)
//        messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func setUpViewController() {
        title = "Bet Details"
        closeBetButton.layer.cornerRadius = 15
        betCard.layer.cornerRadius = 30
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(UINib(nibName: K.cells.messageCell, bundle: nil),
                                  forCellReuseIdentifier: K.cells.messageCell)
        updateBetCard()
        titleLabel.text = nil
    }

    func initViewModel() {
        viewModel.updateBetCard = { [weak self] in
            self?.updateBetCard()
        }
        viewModel.fetchBet()
    }
    
    func updateBetCard() {
        let bet = viewModel.bet
        switch bet?.type {
        case .spread:
            titleLabel.text = bet?.title
            betTypeLabel.text = bet?.type.rawValue.capitalized
            leftLabel1.text = BetDetailViewModel.Labels.Spread.leftLabel1
            rightLabel1.text = viewModel.getBetLine()
            leftLabel2.text = BetDetailViewModel.Labels.Spread.leftLabel2
            rightLabel2.text = viewModel.getSideNames(forSide: .one)
            leftLabel3.text = BetDetailViewModel.Labels.Spread.leftLabel3
            rightLabel3.text = viewModel.getSideNames(forSide: .two)
            leftLabel4.text = BetDetailViewModel.Labels.Spread.leftLabel4
            rightLabel4.text = viewModel.getDateString()
            leftLabel5.text = BetDetailViewModel.Labels.Spread.leftLabel5
            rightLabel5.text = viewModel.getDateString()
            leftLabel6.text = BetDetailViewModel.Labels.Spread.leftLabel6
            rightLabel6.text = viewModel.getBetStatus()
            
        case .moneyline:
            titleLabel.text = bet?.title
            betTypeLabel.text = bet?.type.rawValue.capitalized
            leftLabel1.text = BetDetailViewModel.Labels.Moneyline.leftLabel1
            rightLabel1.text = nil
            leftLabel2.text = bet?.team1
            rightLabel2.text = viewModel.getSideNames(forSide: .one)
            leftLabel3.text = bet?.team2
            rightLabel3.text = viewModel.getSideNames(forSide: .two)
            leftLabel4.text = BetDetailViewModel.Labels.Moneyline.leftLabel4
            rightLabel4.text = viewModel.getDateString()
            leftLabel5.text = BetDetailViewModel.Labels.Moneyline.leftLabel5
            rightLabel5.text = viewModel.getStakeString()
            leftLabel6.text = BetDetailViewModel.Labels.Moneyline.leftLabel6
            rightLabel6.text = viewModel.getBetStatus()
            
        case .event:
            titleLabel.text = bet?.title
            betTypeLabel.text = bet?.type.rawValue.capitalized
            leftLabel1.text = BetDetailViewModel.Labels.Event.leftLabel1
            rightLabel1.text = nil
            leftLabel2.text = BetDetailViewModel.Labels.Event.leftLabel2
            rightLabel2.text = viewModel.getSideNames(forSide: .one)
            leftLabel3.text = BetDetailViewModel.Labels.Event.leftLabel3
            rightLabel3.text = viewModel.getSideNames(forSide: .two)
            leftLabel4.text = BetDetailViewModel.Labels.Event.leftLabel4
            rightLabel4.text = viewModel.getDateString()
            leftLabel5.text = BetDetailViewModel.Labels.Event.leftLabel5
            rightLabel5.text = viewModel.getStakeString()
            leftLabel6.text = BetDetailViewModel.Labels.Event.leftLabel6
            rightLabel6.text = viewModel.getBetStatus()
            
        case .none:
            titleLabel.text = "Bet not found."
            betTypeLabel.text = nil
            leftLabel1.text = nil
            rightLabel1.text = nil
            leftLabel2.text = nil
            rightLabel2.text = nil
            leftLabel3.text = nil
            rightLabel3.text = nil
            leftLabel4.text = nil
            rightLabel4.text = nil
            leftLabel5.text = nil
            rightLabel5.text = nil
            leftLabel6.text = nil
            rightLabel6.text = nil
            
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
    }
    
}

extension BetDetailViewController: UITableViewDelegate, UITableViewDataSource {
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
