//
//  HairlineView.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/25/20.
//

// Updated from https://gist.github.com/ashchan/fb73e30d471ba5188890

import UIKit

// How to use
//    Drag an UIView to storyboard, set constraints.
//    Set the height constraint priority to less than 1000.
//    The view will override that to half pixel.
class HairlineView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    override func updateConstraints() {
        let height = (1.0 / UIScreen.main.scale)
        addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .height,
                multiplier: 1.0,
                constant: height
            )
        )

        super.updateConstraints()
    }
}
