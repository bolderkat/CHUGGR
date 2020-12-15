//
//  BetsTableDataSource.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/15/20.
//

import UIKit

class BetsTableDataSource: UITableViewDiffableDataSource<BetsViewController.Section, BetCellViewModel> {
    // Data source override to provide section header titles in tableView
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.snapshot().sectionIdentifiers[section]
        return section.header
    }
}
