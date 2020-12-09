//
//  FirestoreHelperTests.swift
//  CHUGGRTests
//
//  Created by Daniel Luo on 12/8/20.
//

@testable import CHUGGR
import XCTest
import Firebase
import FirebaseFirestoreSwift

class FirestoreHelperTests: XCTestCase {
    let db = Firestore.firestore()
    var bet: Bet?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
    
        
        func testReadBet() {
            let expectation = self.expectation(description: "Reading from db")
            readBet(withBetID: "OukDGC0YUgTcT98afOhh") { [weak self] (bet) in
                self?.bet = bet
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 5, handler: nil)
            XCTAssertNotNil(self.bet)
        }
        
}
