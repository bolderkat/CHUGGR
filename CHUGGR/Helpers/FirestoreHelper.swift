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
    private(set) var currentUser: CurrentUser?
    
    // MARK:- User CRUD
    func getCurrentUser(
        with uid: String,
        completion: (() -> ())?,
        failure: (() -> ())?
    ) {
        DispatchQueue.global().async {
            self.db.collection(K.Firestore.users).whereField(K.Firestore.uid, isEqualTo: uid)
                .addSnapshotListener { (querySnapshot, error) in
                    guard let document = querySnapshot?.documents.first else {
                        print("Error fetching documents: \(error!)")
                        return
                        // TODO: Robust error handling
                    }
                    let result = Result {
                        try document.data(as: CurrentUser.self)
                    }
                    switch result {
                    case .success(let user):
                        if let user = user {
                            self.currentUser = user
                            completion?()
                        } else {
                            print("Document does not exist")
                            failure?()
                        }
                    case .failure(let error):
                        print("Error decoding user: \(error)")
                        failure?()
                    }
                }
        }
    }
    
    
    
    
    
    // MARK:- Bet CRUD
    func writeNewBet(bet: inout Bet) -> String? {
        let ref = db.collection(K.Firestore.bets).document()
        bet.setBetID(withID: ref.documentID) // add auto-gen betID to bet for reads
        do {
            
            try ref.setData(from: bet)
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
    
//    func getBetFirstNames(from bet: Bet) -> (side 1: [String], side2: [String]) {
//        // Go thru users collection and grab first names from matching user docs
//    }
    
}
