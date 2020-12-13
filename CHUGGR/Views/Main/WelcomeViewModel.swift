//
//  WelcomeViewModel.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/10/20.
//

import Foundation

class WelcomeViewModel {
    private let firestoreHelper: FirestoreHelper
    var onUserRead: (() -> ())?
    var onUserDocNotFound: (() -> ())?
    var onUserReadFail: (() -> ())?
    
    init(firestoreHelper: FirestoreHelper) {
        self.firestoreHelper = firestoreHelper
    }
    
    func getCurrentUserDetails(with uid: String) {
        firestoreHelper.readUserOnLogin(
            with: uid,
            completion: onUserRead,
            onUserDocNotFound: onUserDocNotFound,
            failure: onUserReadFail
        )
    }
}
