//
//  User.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/21/20.
//

import Foundation

protocol User {
    var uuid: String { get }
    var email: String { get }
    var firstName: String { get }
    var lastName: String { get }
    var fullName: String { get }
    
}
