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
    
    
    // MARK:- User CRUD
    func getCurrentUser(withID id: String, completion: @escaping (_ user: CurrentUser) -> ()) {
        
    }
    
    
    
    
    
    // MARK:- Bet CRUD
    func writeNewBet(bet: Bet) -> String? {
        let ref = db.collection(K.Firestore.bets).document()
        
        do {
            try ref.setData(from: bet)
            ref.updateData(["betID": ref.documentID]) // add auto-gen betID to doc for reads
        } catch {
            print("Error writing bet to db")
            return nil
            // TODO: full error handling
        }
        return ref.documentID
    }
    
    func readBet(withBetID id: String?, completion: @escaping (_ bet: Bet) -> ()) {
        guard let id = id else { return }
        DispatchQueue.global().async {
            self.db.collection(K.Firestore.bets).whereField(K.Firestore.betID, isEqualTo: id)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        let document = querySnapshot!.documents.first
                        let result = Result {
                            try document?.data(as: Bet.self)
                        }
                        switch result {
                        case .success(let betFromDoc):
                            if let unwrappedBet = betFromDoc {
                                // Successfully initialized a Bet value from DocumentSnapshot
                                completion(unwrappedBet)
                            } else {
                                // A nil value was successfully initialized from the DocumentSnapshot,
                                // or the DocumentSnapshot was nil.
                                print("Document does not exist")
                            }
                        case .failure(let error):
                            // A Bet value could not be initialized from the DocumentSnapshot.
                            print("Error decoding bet: \(error)")
                        }
                    }
                }
        }
    }
    
}
