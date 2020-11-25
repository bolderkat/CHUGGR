//
//  NewBetViewController.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/25/20.
//

import UIKit

class NewBetViewController: UIViewController, Storyboarded {

    weak var coordinator: ChildCoordinating?
    @IBOutlet weak var topControl: UISegmentedControl!
    @IBOutlet weak var entryTable: UITableView!
    @IBOutlet weak var bottomControl: UISegmentedControl!
    @IBOutlet weak var sendBetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipient goes here" // TODO: update dynamically based on selected friend
        sendBetButton.layer.cornerRadius = 15
    }

}
