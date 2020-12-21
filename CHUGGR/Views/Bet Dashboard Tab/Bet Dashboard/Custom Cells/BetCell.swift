//
//  BetCell.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/7/20.
//

import UIKit

class BetCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var side1Label: UILabel!
    @IBOutlet weak var side1NamesLabel: UILabel!
    @IBOutlet weak var side2Label: UILabel!
    @IBOutlet weak var side2NamesLabel: UILabel!
    @IBOutlet weak var stakeLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(withVM vm: BetCellViewModel) {
        titleLabel.text = vm.bet.title
        side1Label.text = vm.getSideLabels(for: .one)
        side1NamesLabel.text = vm.getSideNames(for: .one)
        side2Label.text = vm.getSideLabels(for: .two)
        side2NamesLabel.text = vm.getSideNames(for: .two)
        stakeLabel.text = vm.getStakeString()
        resultLabel.text = vm.getBetStatusAndColor().label
        resultLabel.textColor = UIColor(named: vm.getBetStatusAndColor().color)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
