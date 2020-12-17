//
//  Friend.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/16/20.
//

import Foundation

protocol Friend {
    var uid: UID { get }
    var firstName: String { get }
    var lastName: String { get }
    var userName: String { get }
    var profilePic: String { get }
}
