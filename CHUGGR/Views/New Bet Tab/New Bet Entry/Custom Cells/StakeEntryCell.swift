//
//  StakeEntryCell.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/1/20.
//

import UIKit

class StakeEntryCell: UITableViewCell {

    @IBOutlet weak var beerField: UITextField!
    @IBOutlet weak var shotField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
