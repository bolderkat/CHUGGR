//
//  FirestoreHelper.swift
//  CHUGGR
//
//  Created by Daniel Luo on 12/7/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirestoreHelper {
    private let db = Firestore.firestore()
    
    func writeNewBet(bet: Bet) {
        do {
            let ref = db.collection(K.Firestore.bets).document()
            try ref.setData(from: bet)
        } catch {
            print("Error writing bet to db") // TODO: full error handling
        }
    }
    
}
