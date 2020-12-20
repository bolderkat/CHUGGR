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
    @IBOutlet weak var betCard: UIView!

    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var fourthButton: UIButton!

    @IBOutlet weak var bottomSendView: UIView!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
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
        configureTableView()
        
//        messageTableView.rowHeight = UITableView.automaticDimension
//
//        messageTableView.estimatedRowHeight = 200

        // scroll to bottom of table, to put in message load/sort function later
//        let indexPath = IndexPath(row: messages.count - 1, section: 0)
//        messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func setUpViewController() {
        title = "Bet Details"
        firstButton.layer.cornerRadius = 15
        secondButton.layer.cornerRadius = 15
        thirdButton.layer.cornerRadius = 15
        fourthButton.layer.cornerRadius = 15
        betCard.layer.cornerRadius = 30
        setUpForInvolvementState()
        updateBetCard()
        titleLabel.text = nil
    }
    

    func initViewModel() {
        viewModel.updateBetCard = { [weak self] in
            DispatchQueue.main.async {
                self?.updateBetCard()
            }
        }
        
        viewModel.setUpForInvolvementState = { [weak self] in
            DispatchQueue.main.async {
                self?.setUpForInvolvementState()
            }
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
            rightLabel5.text = viewModel.getStakeString()
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
    
    func setUpForInvolvementState() {
        switch viewModel.userInvolvement {
        case .invited:
            setUpForInvitedState()
        case .accepted:
            setUpForAcceptedState()
        case .uninvolved:
            setUpForUninvolvedState()
        case .closed:
            return // TODO: handle this case
        }
    }
    
    func setUpForInvitedState() {
        messageTableView.isHidden = true
        bottomSendView.isHidden = true
        firstButton.backgroundColor = UIColor(named: K.colors.forestGreen)
        firstButton.setTitle(viewModel.getButtonStrings().side1, for: .normal)
        secondButton.isHidden = false
        secondButton.setTitle(viewModel.getButtonStrings().side2, for: .normal)
        secondButton.backgroundColor = UIColor(named: K.colors.forestGreen)
        thirdButton.isHidden = false
        fourthButton.isHidden = false
        // TODO: Get these labels to update as the segue occurs instead of after
    }
    
    func setUpForAcceptedState() {
        // Show delete button.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteBet))
        
        messageTableView.isHidden = false
        bottomSendView.isHidden = false
        firstButton.isEnabled = true
        firstButton.backgroundColor = UIColor(named: K.colors.orange)
        firstButton.setTitle("CLOSE BET", for: .normal)
        secondButton.isHidden = true
        thirdButton.isHidden = true
        fourthButton.isHidden = true
        bottomTableViewConstraint.constant = 0
    }
    
    func setUpForUninvolvedState() {
        // Remove delete button if present
        navigationItem.rightBarButtonItem = nil

        firstButton.isEnabled = false
        firstButton.backgroundColor = UIColor(named: K.colors.gray3)
        bottomSendView.isHidden = true
        bottomTableViewConstraint.constant = -bottomSendView.frame.height
    }
    
    @objc func deleteBet() {
        // TODO: need to decrement bet counts etc. for all involved users when bet is deleted.
        guard let betID = viewModel.bet?.betID else { return }
        let alert = UIAlertController(
            title: "Delete bet?",
            message: "Careful. No amount of beer can bring it back.",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "Delete",
                style: .destructive
            ) { [weak self] _ in
                self?.viewModel.deleteBet(withBetID: betID)
                self?.coordinator?.pop()
        })
        present(alert, animated: true)
        
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
    }
    
}

extension BetDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func configureTableView() {
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(UINib(nibName: K.cells.messageCell, bundle: nil),
                                  forCellReuseIdentifier: K.cells.messageCell)
    }
    
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
