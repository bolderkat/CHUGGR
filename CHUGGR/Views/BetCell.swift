//
//  BetCell.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/7/20.
//

import UIKit

class BetCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var betDescription: UILabel!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var result: UILabel!

    var bet: Bet! {
        didSet {
            name.text = bet.name
            betDescription.text = bet.betDescription
            currency.text = bet.currency
            result.text = bet.result
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
