//
//  ProfileViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/11/20.
//

import Foundation
import Firebase

class ProfileViewModel {
    private let firestoreHelper: FirestoreHelper
    
    init(firestoreHelper: FirestoreHelper) {
        self.firestoreHelper = firestoreHelper
    }
    
    func logOut() {
        firestoreHelper.logOut()
    }
}
