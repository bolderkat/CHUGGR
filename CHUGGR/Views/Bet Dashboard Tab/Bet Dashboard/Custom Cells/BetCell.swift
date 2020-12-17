//
//  BetCell.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/7/20.
//

import UIKit

class BetCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNamesLabel: UILabel!
    @IBOutlet weak var stakeLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(withVM vm: BetCellViewModel) {
        userNamesLabel.text = vm.getBothSideNames() // TODO: display proper side names
        titleLabel.text = vm.bet.title
        stakeLabel.text = vm.getStakeString()
        resultLabel.text = vm.getBetStatus()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
