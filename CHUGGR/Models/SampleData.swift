//
//  SampleData.swift
//  CHUGGR
//
//  Created by Daniel Edward Luo on 10/10/20.
//

import Foundation

class SampleData {
    // MARK:- data for testing
    let pending = ["3 New Bets Pending!", "4 🍺"]
    let bets: [Bet] = [
        Bet(name: "David", betDescription: "OVER Alex Caruso points: 6", currency: "1 🍺", result: "IN PLAY"),
        Bet(name: "Torrance", betDescription: "Packers LOSE vs Seahawks", currency: "2 🍺", result: "WON")
    ]
    
    let otherBets: [Bet] = [
        Bet(name: "Derek vs. Micekey", betDescription: "Packers LOSE vs Seahawks", currency: "1 🍺", result: "DEREK WON"),
        Bet(name: "2 people vs. 2 people", betDescription: "A's win ALCS", currency: "1 🍺 1 🥃", result: "IN PLAY"),
        Bet(name: "Torrance", betDescription: "UCLA gets accredited", currency: "6 🍺 9 🥃", result: "LOST"),
        Bet(name: "Cheung vs. Linkous", betDescription: "EPL plays full season", currency: "1 🍺 1 🥃", result: "IN PLAY")
    ]

    let messages: [Message] = [
        Message(sender: "tk@tk.com", body: "I'm gonna win"),
        Message(sender: "dm@dm.com", body: "No I'm gonna win"),
        Message(sender: "tk@tk.com", body: "No u"),
        Message(sender: "dm@dm.com", body: "Yes exactly"),
        Message(sender: "tk@tk.com", body: "No wait"),
        Message(sender: "tk@tk.com", body: "No me"),
        Message(sender: "dm@dm.com", body: "Too late")
    ]
}
