//
//  LiveMatchTest.swift
//  Pickleball ProTests
//
//  Created by Eric Romrell on 8/17/21.
//

import XCTest
@testable import Pickleball_Pro

class LiveMatchTest: XCTestCase {
    func testSinglesServerRotation() throws {
        var match = LiveMatch(
            team1: LiveMatchTeam(player1: LiveMatchPlayer(player: Player(id: "1", name: "", imageUrl: ""), servingState: .serving())),
            team2: LiveMatchTeam(player1: LiveMatchPlayer(player: Player(id: "2", name: "", imageUrl: "")))
        )
        match.rotateServer()
        XCTAssertFalse(match.team1.isServing)
        XCTAssertFalse(match.team1.player1.isServing)
        XCTAssertTrue(match.team2.isServing)
        XCTAssertTrue(match.team2.player1.isServing)
        
        match.rotateServer()
        XCTAssertTrue(match.team1.isServing)
        XCTAssertTrue(match.team1.player1.isServing)
        XCTAssertFalse(match.team2.isServing)
        XCTAssertFalse(match.team2.player1.isServing)
    }
    
    func testDoublesServerRotation() throws {
        var match = LiveMatch(
            team1: LiveMatchTeam(
                player1: LiveMatchPlayer(player: Player(id: "1", name: "", imageUrl: ""), servingState: .serving(isFirstServer: false)),
                player2: LiveMatchPlayer(player: Player(id: "2", name: "", imageUrl: ""))
            ),
            team2: LiveMatchTeam(
                player1: LiveMatchPlayer(player: Player(id: "3", name: "", imageUrl: "")),
                player2: LiveMatchPlayer(player: Player(id: "4", name: "", imageUrl: ""))
            )
        )
        
        match.rotateServer()
        
        switch match.team2.player1.servingState {
        case .serving(let isFirstServer):
            XCTAssertTrue(isFirstServer)
        default:
            XCTFail()
        }
        XCTAssertFalse(match.team1.player1.isServing)
        XCTAssertFalse(match.team1.player2!.isServing)
        XCTAssertFalse(match.team2.player2!.isServing)
        
        match.rotateServer()
        
        switch match.team2.player2!.servingState {
        case .serving(let isFirstServer):
            XCTAssertFalse(isFirstServer)
        default:
            XCTFail()
        }
        XCTAssertFalse(match.team1.player1.isServing)
        XCTAssertFalse(match.team1.player2!.isServing)
        XCTAssertFalse(match.team2.player1.isServing)
        
        match.rotateServer()
        
        switch match.team1.player1.servingState {
        case .serving(let isFirstServer):
            XCTAssertTrue(isFirstServer)
        default:
            XCTFail()
        }
        XCTAssertFalse(match.team1.player2!.isServing)
        XCTAssertFalse(match.team2.player1.isServing)
        XCTAssertFalse(match.team2.player2!.isServing)
        
        match.rotateServer()
        
        switch match.team1.player2!.servingState {
        case .serving(let isFirstServer):
            XCTAssertFalse(isFirstServer)
        default:
            XCTFail()
        }
        XCTAssertFalse(match.team1.player1.isServing)
        XCTAssertFalse(match.team2.player1.isServing)
        XCTAssertFalse(match.team2.player2!.isServing)
    }
    
    func testSinglesPointFinished() {
        var match = LiveMatch(
            team1: LiveMatchTeam(player1: LiveMatchPlayer(player: Player(id: "1", name: "", imageUrl: ""), servingState: .serving())),
            team2: LiveMatchTeam(player1: LiveMatchPlayer(player: Player(id: "2", name: "", imageUrl: "")))
        )
        match.pointFinished(with: Stat.Shot(type: .drive, result: .winner, side: .forehand), by: match.team1.player1)
        
        XCTAssertEqual(match.team1.scores.last, 1)
        XCTAssertEqual(match.team2.scores.last, 0)
        XCTAssertTrue(match.team1.isServing)
        XCTAssertFalse(match.team2.isServing)
        
        match.pointFinished(with: Stat.Shot(type: .drop, result: .error, side: .backhand), by: match.team1.player1)
        
        XCTAssertEqual(match.team1.scores.last, 1)
        XCTAssertEqual(match.team2.scores.last, 0)
        XCTAssertFalse(match.team1.isServing)
        XCTAssertTrue(match.team2.isServing)
        
        match.pointFinished(with: Stat.Shot(type: .drop, result: .error, side: .backhand), by: match.team1.player1)
        
        XCTAssertEqual(match.team1.scores.last, 1)
        XCTAssertEqual(match.team2.scores.last, 1)
        XCTAssertFalse(match.team1.isServing)
        XCTAssertTrue(match.team2.isServing)
        
        match.pointFinished(with: Stat.Shot(type: .drop, result: .winner, side: .backhand), by: match.team1.player1)
        
        XCTAssertEqual(match.team1.scores.last, 1)
        XCTAssertEqual(match.team2.scores.last, 1)
        XCTAssertTrue(match.team1.isServing)
        XCTAssertFalse(match.team2.isServing)
    }
    
    func testDoublesPointFinished() {
        var match = LiveMatch(
            team1: LiveMatchTeam(
                player1: LiveMatchPlayer(player: Player(id: "1", name: "", imageUrl: ""), servingState: .serving(isFirstServer: false)),
                player2: LiveMatchPlayer(player: Player(id: "2", name: "", imageUrl: ""))
            ),
            team2: LiveMatchTeam(
                player1: LiveMatchPlayer(player: Player(id: "3", name: "", imageUrl: "")),
                player2: LiveMatchPlayer(player: Player(id: "4", name: "", imageUrl: ""))
            )
        )
        
        match.pointFinished(with: Stat.Shot(type: .dink, result: .winner, side: .backhand), by: match.team1.player1)
        
        XCTAssertEqual(match.team1.scores.last, 1)
        XCTAssertEqual(match.team2.scores.last, 0)
        XCTAssertEqual(match.team1.player1.id, "2")
        XCTAssertEqual(match.team1.player2!.id, "1")
        XCTAssertEqual(match.team2.player1.id, "3")
        XCTAssertEqual(match.team2.player2!.id, "4")
        XCTAssertEqual(match.currentServer.id, "1")
        
        match.pointFinished(with: Stat.Shot(type: .dink, result: .winner, side: .backhand), by: match.team1.player2!)
        
        XCTAssertEqual(match.team1.scores.last, 2)
        XCTAssertEqual(match.team2.scores.last, 0)
        XCTAssertEqual(match.team1.player1.id, "1")
        XCTAssertEqual(match.team1.player2!.id, "2")
        XCTAssertEqual(match.team2.player1.id, "3")
        XCTAssertEqual(match.team2.player2!.id, "4")
        XCTAssertEqual(match.currentServer.id, "1")
        
        match.pointFinished(with: Stat.Shot(type: .dink, result: .error, side: .backhand), by: match.team2.player2!)
        
        XCTAssertEqual(match.team1.scores.last, 3)
        XCTAssertEqual(match.team2.scores.last, 0)
        XCTAssertEqual(match.team1.player1.id, "2")
        XCTAssertEqual(match.team1.player2!.id, "1")
        XCTAssertEqual(match.team2.player1.id, "3")
        XCTAssertEqual(match.team2.player2!.id, "4")
        XCTAssertEqual(match.currentServer.id, "1")
        
        match.pointFinished(with: Stat.Shot(type: .dink, result: .error, side: .backhand), by: match.team1.player2!)
        
        XCTAssertEqual(match.team1.scores.last, 3)
        XCTAssertEqual(match.team2.scores.last, 0)
        XCTAssertEqual(match.team1.player1.id, "2")
        XCTAssertEqual(match.team1.player2!.id, "1")
        XCTAssertEqual(match.team2.player1.id, "3")
        XCTAssertEqual(match.team2.player2!.id, "4")
        XCTAssertEqual(match.currentServer.id, "3")
        
        match.pointFinished(with: Stat.Shot(type: .dink, result: .winner, side: .backhand), by: match.team2.player2!)
        
        XCTAssertEqual(match.team1.scores.last, 3)
        XCTAssertEqual(match.team2.scores.last, 1)
        XCTAssertEqual(match.team1.player1.id, "2")
        XCTAssertEqual(match.team1.player2!.id, "1")
        XCTAssertEqual(match.team2.player1.id, "4")
        XCTAssertEqual(match.team2.player2!.id, "3")
        XCTAssertEqual(match.currentServer.id, "3")
    }
}
