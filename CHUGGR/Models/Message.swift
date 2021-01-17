//
//  Message.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/10/20.
//

import Foundation

struct Message: Codable {
    let uid: UID
    let userName: String
    let body: String
    let timestamp: TimeInterval
}
