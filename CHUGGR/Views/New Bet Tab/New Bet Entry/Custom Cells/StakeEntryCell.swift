//
//  StakeEntryCell.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/1/20.
//

import UIKit

class StakeEntryCell: UITableViewCell {

    var onStakeInput: ((String?, String?) -> ())?
    
    @IBOutlet private weak var beerField: UITextField!
    @IBOutlet private weak var shotField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        beerField.delegate = self
        beerField.keyboardType = .numberPad
        beerField.addDoneButtonOnKeyboard()
        
        shotField.delegate = self
        shotField.keyboardType = .numberPad
        shotField.addDoneButtonOnKeyboard()
    }
    
    func configure() {
        beerField.text = ""
        shotField.text = ""
    }
    
}

extension StakeEntryCell: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String)
    -> Bool {
        
        // Limit to 1 character
        let characterLimit = 1
        
        // Determine length of new entry
        let startingLength = textField.text?.count ?? 0
        let lengthToAdd = string.count
        let lengthToReplace = range.length
        let newLength = startingLength + lengthToAdd - lengthToReplace

        // Filter out any non-numeric entries.
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
        // Only allow text field change if less than 1 chars and if only numbers.
        return newLength <= characterLimit && string == numberFiltered
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        onStakeInput?(beerField.text, shotField.text)
    }
}
