//
//  DateEntryCell.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/4/20.
//

import UIKit

class DateEntryCell: UITableViewCell {

    var onDateInput: ((TimeInterval) -> ())?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(withVM vm: BetEntryCellViewModel) {
        titleLabel.text = vm.title
        datePicker.date = Date.init()
    }
    
    @IBAction func dateSelected(_ sender: UIDatePicker) {
        let selectedDateInterval = datePicker.date.timeIntervalSince1970
        onDateInput?(selectedDateInterval)
    }
    
}
