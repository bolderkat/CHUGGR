//
//  BetEntryCell.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/25/20.
//

import UIKit

class BetEntryCell: UITableViewCell {
    
    var rowType: BetEntryRowType = .stat // providing default so not optional
    var onTextInput: ((String, BetEntryRowType) -> ())?
    var onDateInput: ((TimeInterval) -> ())?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self

    }
    // TODO: Use UITextView for title entry fields to allow for multi-line input
    
    func configure(withVM vm: BetEntryCellViewModel) {
        // Make sure textfields are empty when cell reused
        titleLabel.text = vm.title
        textField.placeholder = vm.placeholder ?? ""
        textField.text = ""
        rowType = vm.type
    }
}

// MARK:- Text field delegate
extension BetEntryCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch rowType {
        case .line:
            textField.keyboardType = .decimalPad
            textField.addDoneButtonOnKeyboard()
        case .gameday, .dueDate:
            textField.setInputViewDatePicker(target: self, selector: #selector(datePickerDoneTapped))
        case .event, .stat, .team1, .team2:
            textField.keyboardType = .default
        case .stake:
            return
        }
    }
    
    // From https://www.swiftdevcenter.com/uidatepicker-as-input-view-to-uitextfield-swift/
    // Note iOS 14 will use DateEntryCell with compact date picker instead.
    @objc func datePickerDoneTapped() {
        if let datePicker = textField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            textField.text = dateFormatter.string(from: datePicker.date)
            onDateInput?(datePicker.date.timeIntervalSince1970)
        }
        textField.resignFirstResponder()
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        switch rowType {
        case .line:
            // Filter out any non-numeric/non-decimal point entries if line entry cell
            let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            
            // Allow entry of only one decimal point
            let numberOfDecimals = textField.text?.filter { $0 == "." }.count ?? 0
            if numberOfDecimals == 1 && string == "." {
                return false
            } else {
                return string == numberFiltered
            }
        case .dueDate, .event, .gameday, .stake, .stat, .team1, .team2:
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let input = textField.text else { return }
        onTextInput?(input, rowType)
    }
    
    
}
