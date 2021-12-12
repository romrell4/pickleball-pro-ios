//
//  MatchTest.swift
//  Pickleball ProTests
//
//  Created by Eric Romrell on 8/8/21.
//

import XCTest

@testable import Pickleball_Pro

class MatchTest: XCTestCase {
    func testGroupingFiltering() throws {
        let match = Match(
            id: "m1",
            date: Date(),
            team1: [
                Player(id: "p1", firstName: "", lastName: "", imageUrl: ""),
                Player(id: "p2", firstName: "", lastName: "", imageUrl: ""),
            ],
            team2: [
                Player(id: "p3", firstName: "", lastName: "", imageUrl: ""),
                Player(id: "p4", firstName: "", lastName: "", imageUrl: ""),
            ],
            scores: [],
            stats: [
                Stat(playerId: "p1", gameIndex: 0, shotType: .serve, shotResult: .winner),
                Stat(playerId: "p1", gameIndex: 1, shotType: .serve, shotResult: .winner),
                Stat(playerId: "p2", gameIndex: 0, shotType: .serve, shotResult: .winner),
                Stat(playerId: "p3", gameIndex: 0, shotType: .serve, shotResult: .winner),
            ]
        )
        XCTAssertEqual(match.statGroupings().first { $0.label == "Total Winners" }?.team1Amount, 3)
        XCTAssertEqual(match.statGroupings().first { $0.label == "Total Winners" }?.team2Amount, 1)
        
        XCTAssertEqual(match.statGroupings().first { $0.label == "Total Errors" }?.team1Amount, 0)
        XCTAssertEqual(match.statGroupings().first { $0.label == "Total Errors" }?.team2Amount, 0)
        
        XCTAssertEqual(match.statGroupings().first { $0.label == "Aces" }?.team1Amount, 3)
        XCTAssertEqual(match.statGroupings().first { $0.label == "Aces" }?.team2Amount, 1)
        
        XCTAssertEqual(match.statGroupings().first { $0.label == "Aces" }?.team1Amount, 3)
        XCTAssertEqual(match.statGroupings().first { $0.label == "Aces" }?.team2Amount, 1)
        
        XCTAssertEqual(match.statGroupings(gameIndex: 0).first { $0.label == "Aces" }?.team1Amount, 2)
        XCTAssertEqual(match.statGroupings(gameIndex: 0).first { $0.label == "Aces" }?.team2Amount, 1)
        
        XCTAssertEqual(match.statGroupings(gameIndex: 0, playerIds: ["p1", "p2"]).first { $0.label == "Aces" }?.team1Amount, 1)
        XCTAssertEqual(match.statGroupings(gameIndex: 0, playerIds: ["p1", "p2"]).first { $0.label == "Aces" }?.team2Amount, 1)
        
        XCTAssertEqual(match.statGroupings(gameIndex: 1, playerIds: ["p1", "p2"]).first { $0.label == "Aces" }?.team1Amount, 1)
        XCTAssertEqual(match.statGroupings(gameIndex: 1, playerIds: ["p1", "p2"]).first { $0.label == "Aces" }?.team2Amount, 0)
        
        XCTAssertEqual(match.statGroupings(gameIndex: 2, playerIds: ["p1", "p2"]).first { $0.label == "Aces" }?.team1Amount, 0)
        XCTAssertEqual(match.statGroupings(gameIndex: 2, playerIds: ["p1", "p2"]).first { $0.label == "Aces" }?.team2Amount, 0)
    }
    
    func testPlayerResults() throws {
        let match = Match(id: "1", date: Date(), team1: [Player.bob], team2: [Player.eric], scores: [GameScore(team1Score: 10, team2Score: 4)], stats: [])
        XCTAssertEqual(match.result(for: Player.bob), PlayerMatchResult.win)
        XCTAssertEqual(match.result(for: Player.eric), PlayerMatchResult.loss)
        XCTAssertEqual(match.result(for: Player.jessica), PlayerMatchResult.didNotPlay)
        
        let tieMatch = Match(
            id: "1",
            date: Date(),
            team1: [Player.bob, Player.bryan],
            team2: [Player.eric, Player.jessica],
            scores: [
                GameScore(team1Score: 10, team2Score: 4),
                GameScore(team1Score: 2, team2Score: 10)
            ],
            stats: []
        )
        XCTAssertEqual(tieMatch.result(for: Player.bob), PlayerMatchResult.tie)
        XCTAssertEqual(tieMatch.result(for: Player.bryan), PlayerMatchResult.tie)
        XCTAssertEqual(tieMatch.result(for: Player.eric), PlayerMatchResult.tie)
        XCTAssertEqual(tieMatch.result(for: Player.jessica), PlayerMatchResult.tie)
        XCTAssertEqual(tieMatch.result(for: Player.mark), PlayerMatchResult.didNotPlay)
    }
}
