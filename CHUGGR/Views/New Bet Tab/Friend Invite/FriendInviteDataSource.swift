//
//  FriendInviteDataSource.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/18/20.
//

import UIKit

class FriendInviteDataSource: UITableViewDiffableDataSource<FriendInviteViewController.Section, InviteCellViewModel> {
    // Data source override to provide section header titles in tableView
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.snapshot().sectionIdentifiers[section]
        return section.header
    }
}
