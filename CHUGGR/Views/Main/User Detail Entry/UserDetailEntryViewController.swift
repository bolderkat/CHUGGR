//
//  UserDetailEntryViewController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/10/20.
//

import UIKit

class UserDetailEntryViewController: UIViewController {

    weak var mainCoordinator: MainCoordinator?
    private var dataSource: UITableViewDiffableDataSource<Section, UserDetailEntryCellViewModel>!
    private let viewModel: UserDetailEntryViewModel
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var usernameTakenLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboard() // dismiss keyboard on tap outside keyboard
        configureDataSource()
        initViewModel()
        setUpViewController()
        configureTableView()
    }
    
    // Custom init help from https://stackoverflow.com/a/58017901
    init(viewModel: UserDetailEntryViewModel,
         nibName: String? = nil,
         bundle: Bundle? = nil
    ) {
        self.viewModel = viewModel
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViewController() {
        submitButton.layer.cornerRadius = 15
        updateButtonStatus()
    }
    
    func initViewModel() {
        viewModel.reloadTableViewClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
        
        viewModel.updateButtonStatus = { [weak self] in
            DispatchQueue.main.async {
                self?.updateButtonStatus()
            }
        }
        
        viewModel.ifUserNameTaken = { [weak self] in
            DispatchQueue.main.async {
                self?.showUsernameTakenLabel()
            }
        }
        
        viewModel.onUserLoad = { [weak self] in
            DispatchQueue.main.async {
                // notes from Ian call: switch on result to decide if see should go to dashboard or display username error
                // Allows us to consolidate ifUserNameTaken into this one closure
                self?.proceedToDashboard()
            }
        }
        
        viewModel.createCellVMs()
    }
    
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        viewModel.submitInput()
        usernameTakenLabel.isHidden = true
        // TODO: show loading indicator?
    }
    
    private func proceedToDashboard() {
        // Call coordinator to go to tab bar controller
        if let coordinator = mainCoordinator {
            coordinator.goToTabBar()
        }
    }
    
    private func showUsernameTakenLabel() {
        usernameTakenLabel.isHidden = false
    }
}

// MARK:- Table View Data Source

extension UserDetailEntryViewController {
    enum Section {
        case main
    }
    
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, UserDetailEntryCellViewModel>(
            tableView: tableView) { (tableView, indexPath, rowVM) -> UITableViewCell? in
            
            // Set up each row type and return cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.cells.userEntryCell) as? UserDetailEntryCell else {
                fatalError("User detail entry cell nib does not exist")
            }
            cell.configure(withVM: rowVM)
            cell.onTextInput = self.viewModel.handle(text:for:)
            return cell
        }
    }
    
    func updateUI(animated: Bool = false) {
        // Set up table rows
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserDetailEntryCellViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.cellViewModels)
        dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
    }
    
    func updateButtonStatus() {
        submitButton.isEnabled = viewModel.isInputComplete
        submitButton.backgroundColor = submitButton.isEnabled ?
            UIColor(named: K.colors.orange) : UIColor(named: K.colors.gray3)
    }
}


// MARK:- Table View Delegate

extension UserDetailEntryViewController: UITableViewDelegate {
    func configureTableView() {
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: K.cells.userEntryCell, bundle: nil),
                           forCellReuseIdentifier: K.cells.userEntryCell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Provide taller cell for bio field
        let cell = viewModel.getCellViewModel(at: indexPath)
        if cell.type == .bio {
            return 140
        } else {
            return 50
        }
    }
}
