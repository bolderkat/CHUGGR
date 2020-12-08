//
//  UITextField+InputView.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/4/20.
//

import UIKit

// From https://www.swiftdevcenter.com/uidatepicker-as-input-view-to-uitextfield-swift/

extension UITextField {
    
    func setInputViewDatePicker(target: Any, selector: Selector) {
        // Create a UIDatePicker object and assign to inputView
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(
            frame: CGRect(
                x: 0,
                y: 0,
                width: screenWidth,
                height: 216
            )
        )
        datePicker.datePickerMode = .dateAndTime
        
        // for iOS 14 and above
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        
        self.inputView = datePicker // pull up date picker when text field tapped
        
        // Create a toolbar and assign it to inputAccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        ) // fills empty space on bar
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel))
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector)
        toolBar.setItems([cancel, flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
    
    @objc private func tapCancel() {
        self.resignFirstResponder()
    }
}
