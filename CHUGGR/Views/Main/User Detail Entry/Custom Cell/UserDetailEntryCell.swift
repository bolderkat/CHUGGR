//
//  UserDetailEntryCell.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/10/20.
//

import UIKit

class UserDetailEntryCell: UITableViewCell {
    
    var rowType: UserEntryRowType?
    var onTextInput: ((String, UserEntryRowType) -> ())?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        textView.delegate = self
    }
    
}

extension UserDetailEntryCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch rowType {
        case .userName:
            textField.autocapitalizationType = .none
        default:
            textField.autocapitalizationType = .words
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Limit to 25 characters.
        let characterLimit = 25
        
        let startingLength = textField.text?.count ?? 0
        let lengthToAdd = string.count
        let lengthToReplace = range.length
        let newLength = startingLength + lengthToAdd - lengthToReplace
        return newLength <= characterLimit
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let input = textField.text, let rowType = rowType else { return }
        onTextInput?(input, rowType)
    }
}

extension UserDetailEntryCell: UITextViewDelegate {
    
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String) -> Bool {
        
        // Prevent user from entering new line, also dismisses on return key press.
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        // Limit to 140 characters.
        let characterLimit = 140
        
        let startingLength = textView.text.count
        let lengthToAdd = text.count
        let lengthToReplace = range.length
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        return newLength <= characterLimit
        
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let input = textView.text, let rowType = rowType else { return }
        onTextInput?(input, rowType)
    }
}
