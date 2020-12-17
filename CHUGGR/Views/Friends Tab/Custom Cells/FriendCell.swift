//
//  FriendCell.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/15/20.
//

import UIKit

class FriendCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profPicView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(withVM vm: FriendCellViewModel) {
        nameLabel.text = vm.fullName
        userNameLabel.text = vm.userName
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
