//
//  Drinks.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/8/20.
//

import Foundation

struct Drinks: Codable {
    var beers: Int
    var shots: Int
}

enum DrinkStatType: CaseIterable {
    case given
    case received
    case outstanding
}
