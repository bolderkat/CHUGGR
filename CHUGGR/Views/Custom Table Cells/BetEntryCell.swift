//
//  BetEntryCell.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/25/20.
//

import UIKit

class BetEntryCell: UITableViewCell {
    
    var rowType: EntryRowType?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
