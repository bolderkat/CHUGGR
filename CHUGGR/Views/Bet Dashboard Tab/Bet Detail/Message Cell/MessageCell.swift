//
//  MessageCell.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/10/20.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bodyLabel: UITextView!
    @IBOutlet weak var messageBubble: UIView!
    @IBOutlet weak var messageBubbleTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with vm: MessageCellViewModel) {
        messageBubble.layer.cornerRadius = 10
        // Fill labels
        nameLabel.text = vm.message.firstName
        timeLabel.text = vm.getTimeString()
        bodyLabel.text = vm.message.body
        
        // Configure based on who sent message
        if vm.isMessageFromSelf {
            messageBubble.backgroundColor = UIColor(named: K.colors.midBlue)
            bodyLabel.textColor = .white
        } else {
            messageBubble.backgroundColor = UIColor(named: K.colors.gray5)
            bodyLabel.textColor = .black
        }
        
        // Configure to remove sender/time data if previous message from same sender
        if vm.isPreviousMessageFromSameSender {
            nameLabel.isHidden = true
            timeLabel.isHidden = true
            messageBubbleTopConstraint.constant = 1 // bring bubble up to top of cell
        } else {
            nameLabel.isHidden = false
            timeLabel.isHidden = false
            messageBubbleTopConstraint.constant = 26 // return to original distance
        }
    }
}
    
