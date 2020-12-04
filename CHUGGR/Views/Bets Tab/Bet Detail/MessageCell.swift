//
//  MessageCell.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/10/20.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var leftBubble: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageBubble: UIView!
    @IBOutlet weak var rightBubble: UIView!
    @IBOutlet weak var senderContainer: UIView!

    var senderHeightConstraint: NSLayoutConstraint!
    private let senderLabelHeight: CGFloat = 15

    var message: Message! {
        didSet {
            configureCell()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        messageBubble.layer.cornerRadius = messageBubble.frame.size.height / 5
        senderHeightConstraint = senderContainer.heightAnchor.constraint(equalToConstant: senderLabelHeight)
        senderHeightConstraint.isActive = true
        senderContainer.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell() {
        messageLabel.text = message.body
        if message.sender == "tk@tk.com" {
            senderHeightConstraint.constant = 0
            rightBubble.isHidden = true
        } else {
            leftBubble.isHidden = true
            messageBubble.backgroundColor = UIColor(named: K.colors.midGray)
            messageLabel.textColor = UIColor.black
            senderHeightConstraint.constant = senderLabelHeight
            senderLabel.text = message.sender
        }
    }
}
    
