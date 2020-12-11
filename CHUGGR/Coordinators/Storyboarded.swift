//
//  Storyboarded.swift
//  CHUGGR
//
//  Created by Daniel Luo on 11/20/20.
//

import UIKit
// Storyboarded protocol from https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps

protocol Storyboarded: AnyObject {
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        // get the view controller name
        let id = String(describing: self)
        
        // load the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // grab the view controller from the storyboard and instantiate. Can force cast here because VC and storyboard names match
        return storyboard.instantiateViewController(identifier: id) as! Self
    }
}
