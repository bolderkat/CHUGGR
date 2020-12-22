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
    private var yOrigin: CGFloat = 0

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
    @IBOutlet weak var topTableViewConstraint: NSLayoutConstraint!
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
        dismissKeyboard()
        setUpViewController()
        initViewModel()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.checkInvolvementStatus()
        viewModel.setBetListener() // set listener at view appear as it is removed on disappear
        yOrigin = self.view.frame.origin.y // for sliding view with keyboard
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Clean up listener when no longer needed
        viewModel.clearBetListener()
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
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
        textField.delegate = self
        setUpKeyboardNotifications()
    }
    
    func setUpKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // Keyboard selector methods are in textfield delegate extension
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
        
        viewModel.showAlreadyClosedAlert = { [weak self] in
            DispatchQueue.main.async {
                self?.showAlreadyClosedAlert()
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
            rightLabel6.text = viewModel.getBetStatusAndColor().label
            rightLabel6.textColor = UIColor(named: viewModel.getBetStatusAndColor().color)
            
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
            rightLabel6.text = viewModel.getBetStatusAndColor().label
            rightLabel6.textColor = UIColor(named: viewModel.getBetStatusAndColor().color)
            
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
            rightLabel6.text = viewModel.getBetStatusAndColor().label
            rightLabel6.textColor = UIColor(named: viewModel.getBetStatusAndColor().color)
            
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
        case .outstanding:
            setUpForOutstandingState()
        case .closed:
            setUpForClosedState()
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
        firstButton.isHidden = false
        firstButton.backgroundColor = UIColor(named: K.colors.orange)
        firstButton.setTitle("CLOSE BET", for: .normal)
        secondButton.isHidden = true
        thirdButton.isHidden = true
        fourthButton.isHidden = true
        topTableViewConstraint.constant = 10
        bottomTableViewConstraint.constant = 0
    }
    
    func setUpForUninvolvedState() {
        firstButton.backgroundColor = UIColor(named: K.colors.forestGreen)
        firstButton.setTitle(viewModel.getButtonStrings().side1, for: .normal)
        secondButton.isHidden = false
        secondButton.setTitle(viewModel.getButtonStrings().side2, for: .normal)
        secondButton.backgroundColor = UIColor(named: K.colors.forestGreen)
        messageTableView.isHidden = true
        bottomSendView.isHidden = true
        thirdButton.isHidden = true
        fourthButton.isHidden = true
    }
    
    func setUpForOutstandingState() {
        // Remove delete button. You can't escape if you've lost the bet!
        navigationItem.rightBarButtonItem = nil
        
        firstButton.isEnabled = true
        firstButton.isHidden = false
        secondButton.isHidden = true
        thirdButton.isHidden = true
        fourthButton.isHidden = true
        firstButton.backgroundColor = UIColor(named: K.colors.orange)
        firstButton.setTitle("MARK COMPLETE", for: .normal)
        bottomSendView.isHidden = true
        messageTableView.isHidden = false
        topTableViewConstraint.constant = 10
        bottomTableViewConstraint.constant = -bottomSendView.frame.height
    }
    
    func setUpForClosedState() {
        navigationItem.rightBarButtonItem = nil
        
        firstButton.isHidden = true
        secondButton.isHidden = true
        thirdButton.isHidden = true
        fourthButton.isHidden = true
        // Hide chat when bet is closed
        messageTableView.isHidden = true
        bottomSendView.isHidden = true
    }
    
    func showAlreadyClosedAlert() {
        let alert = UIAlertController(title: "Bet already closed", message: "It looks like this bet has recently been closed by another user.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // MARK:- Button Methods
    @objc func deleteBet() {
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
                self?.viewModel.deleteBet()
                self?.coordinator?.pop()
        })
        present(alert, animated: true)
        
    }
    
    @IBAction func firstButtonPressed(_ sender: UIButton) {
        switch viewModel.userInvolvement {
        case .invited:
            viewModel.acceptBet(side: .one)
        case .accepted:
            showWinnerActionSheet()
        case .outstanding:
            showFulfillActionSheet()
        case .uninvolved:
            viewModel.uninvitedJoinBet(side: .one)
        case .closed:
            return
        }
    }
    
    @IBAction func secondButtonPressed(_ sender: UIButton) {
        if viewModel.userInvolvement == .invited {
            viewModel.acceptBet(side: .two)
        } else if viewModel.userInvolvement == .uninvolved {
            viewModel.uninvitedJoinBet(side: .two)
        }
    }
    
    @IBAction func thirdButtonPressed(_ sender: UIButton) {
        if viewModel.userInvolvement == .invited {
            // TODO: go to bet entry page to modify.
        }
    }
    
    @IBAction func fourthButtonPressed(_ sender: UIButton) {
        if viewModel.userInvolvement == .invited {
            let alert = UIAlertController(
                title: "Reject bet?",
                message: "You cannot be added back to the bet!",
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
                    title: "Reject",
                    style: .destructive
                ) { [weak self] _ in
                    self?.viewModel.rejectBet()
            })
            present(alert, animated: true)
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
    }
    
    func showWinnerActionSheet() {
        // Give user options to choose the winner of the bet.
        let alert = UIAlertController(
            title: "Who won?",
            message: "Choose a winner",
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(
                title: viewModel.getActionSheetStrings().side1,
                style: .default
            ) { [weak self] action in
                self?.viewModel.closeBet(withWinner: .one)
            })
        alert.addAction(
            UIAlertAction(
                title: viewModel.getActionSheetStrings().side2,
                style: .default
            ) { [weak self] action in
                self?.viewModel.closeBet(withWinner: .two)
            })
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        present(alert, animated: true)
    }
    
    func showFulfillActionSheet() {
        let alert = UIAlertController(
            title: "CONFIRM",
            message: "Have you fulfilled the bet stake, providing satisfactory proof to the winners of this bet?",
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(
                title: "I promise!",
                style: .default
            ) { [weak self] action in
                self?.viewModel.fulfillBet()
            })
        alert.addAction(
            UIAlertAction(
                title: "Not yet...",
                style: .cancel,
                handler: nil
            )
        )
        present(alert, animated: true)
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

extension BetDetailViewController: UITextFieldDelegate {
    @objc func keyboardWillShow(notification: NSNotification) {
        let key = UIResponder.keyboardFrameEndUserInfoKey
        if let keyboardSize = (notification.userInfo?[key] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == yOrigin {
                self.view.frame.origin.y -= keyboardSize.height - (tabBarController?.tabBar.frame.size.height ?? 0)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != yOrigin {
            self.view.frame.origin.y = yOrigin
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
