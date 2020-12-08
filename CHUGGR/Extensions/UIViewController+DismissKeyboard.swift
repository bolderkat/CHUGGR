//
//  UIViewController+DismissKeyboard.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/7/20.
//

import UIKit

// From https://medium.com/@vvishwakarma/dismiss-hide-keyboard-when-touching-outside-of-uitextfield-swift-166d9d1efb68
extension UIViewController {
    func dismissKeyboard() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboardTouchOutside)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }
}
