//
//  InviteCell.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/17/20.
//

import UIKit

class InviteCell: UITableViewCell {
    
    var viewModel: InviteCellViewModel?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profPicView: UIImageView!
    @IBOutlet weak var circleView: UIImageView!
    @IBOutlet weak var checkmarkView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure() {
        guard let viewModel = viewModel else {
            fatalError("No view model found for invite cell")
        }
        nameLabel.text = viewModel.fullName
        userNameLabel.text = viewModel.userName
        if viewModel.isChecked {
            checkmarkView.isHidden = false
            circleView.isHidden = true
        } else {
            circleView.isHidden = false
            checkmarkView.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
