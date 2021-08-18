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
}
