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
            team1: LiveMatchTeam(deucePlayer: LiveMatchPlayer(player: Player(id: "1", firstName: "", lastName: "", imageUrl: ""), servingState: .serving())),
            team2: LiveMatchTeam(deucePlayer: LiveMatchPlayer(player: Player(id: "2", firstName: "", lastName: "", imageUrl: "")))
        )
        match.sideout()
        XCTAssertFalse(match.team1.isServing)
        XCTAssertFalse(match.team1.deucePlayer!.isServing)
        XCTAssertTrue(match.team2.isServing)
        XCTAssertTrue(match.team2.deucePlayer!.isServing)
        
        match.sideout()
        XCTAssertTrue(match.team1.isServing)
        XCTAssertTrue(match.team1.deucePlayer!.isServing)
        XCTAssertFalse(match.team2.isServing)
        XCTAssertFalse(match.team2.deucePlayer!.isServing)
        
        // Make sure that server side is switched after a sideout
        match.team2.earnPoint()
        match.sideout()
        XCTAssertFalse(match.team1.isServing)
        XCTAssertFalse(match.team1.adPlayer!.isServing)
        XCTAssertTrue(match.team2.isServing)
        XCTAssertTrue(match.team2.adPlayer!.isServing)
        
        match.sideout()
        XCTAssertTrue(match.team1.isServing)
        XCTAssertTrue(match.team1.deucePlayer!.isServing)
        XCTAssertFalse(match.team2.isServing)
        XCTAssertFalse(match.team2.deucePlayer!.isServing)
    }
    
    func testDoublesServerRotation() throws {
        var match = LiveMatch(
            team1: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: Player(id: "1", firstName: "", lastName: "", imageUrl: ""), servingState: .serving(isFirstServer: false)),
                adPlayer: LiveMatchPlayer(player: Player(id: "2", firstName: "", lastName: "", imageUrl: ""))
            ),
            team2: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: Player(id: "3", firstName: "", lastName: "", imageUrl: "")),
                adPlayer: LiveMatchPlayer(player: Player(id: "4", firstName: "", lastName: "", imageUrl: ""))
            )
        )
        
        match.sideout()
        
        switch match.team2.deucePlayer!.servingState {
        case .serving(let isFirstServer):
            XCTAssertTrue(isFirstServer)
        default:
            XCTFail()
        }
        XCTAssertFalse(match.team1.deucePlayer!.isServing)
        XCTAssertFalse(match.team1.adPlayer!.isServing)
        XCTAssertFalse(match.team2.adPlayer!.isServing)
        
        match.sideout()
        
        switch match.team2.adPlayer!.servingState {
        case .serving(let isFirstServer):
            XCTAssertFalse(isFirstServer)
        default:
            XCTFail()
        }
        XCTAssertFalse(match.team1.deucePlayer!.isServing)
        XCTAssertFalse(match.team1.adPlayer!.isServing)
        XCTAssertFalse(match.team2.deucePlayer!.isServing)
        
        match.sideout()
        
        switch match.team1.deucePlayer!.servingState {
        case .serving(let isFirstServer):
            XCTAssertTrue(isFirstServer)
        default:
            XCTFail()
        }
        XCTAssertFalse(match.team1.adPlayer!.isServing)
        XCTAssertFalse(match.team2.deucePlayer!.isServing)
        XCTAssertFalse(match.team2.adPlayer!.isServing)
        
        match.sideout()
        
        switch match.team1.adPlayer!.servingState {
        case .serving(let isFirstServer):
            XCTAssertFalse(isFirstServer)
        default:
            XCTFail()
        }
        XCTAssertFalse(match.team1.deucePlayer!.isServing)
        XCTAssertFalse(match.team2.deucePlayer!.isServing)
        XCTAssertFalse(match.team2.adPlayer!.isServing)
    }
    
    func testSinglesServerUnrotation() throws {
        var match = LiveMatch(
            team1: LiveMatchTeam(deucePlayer: LiveMatchPlayer(player: Player(id: "1", firstName: "", lastName: "", imageUrl: ""), servingState: .serving())),
            team2: LiveMatchTeam(deucePlayer: LiveMatchPlayer(player: Player(id: "2", firstName: "", lastName: "", imageUrl: "")))
        )
        match.unrotateServer(previousServerId: "1", wasFirstServer: true)
        XCTAssertTrue(match.team1.isServing)
        XCTAssertTrue(match.team1.deucePlayer!.isServing)
        XCTAssertFalse(match.team2.isServing)
        XCTAssertFalse(match.team2.deucePlayer!.isServing)
        
        match.unrotateServer(previousServerId: "2", wasFirstServer: true)
        XCTAssertFalse(match.team1.isServing)
        XCTAssertFalse(match.team1.deucePlayer!.isServing)
        XCTAssertTrue(match.team2.isServing)
        XCTAssertTrue(match.team2.deucePlayer!.isServing)
    }
    
    func testDoublesServerUnrotation() throws {
        var match = LiveMatch(
            team1: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: Player(id: "1", firstName: "", lastName: "", imageUrl: ""), servingState: .serving(isFirstServer: false)),
                adPlayer: LiveMatchPlayer(player: Player(id: "2", firstName: "", lastName: "", imageUrl: ""))
            ),
            team2: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: Player(id: "3", firstName: "", lastName: "", imageUrl: "")),
                adPlayer: LiveMatchPlayer(player: Player(id: "4", firstName: "", lastName: "", imageUrl: ""))
            )
        )
        
        match.unrotateServer(previousServerId: "3", wasFirstServer: true)
        
        switch match.team2.deucePlayer!.servingState {
        case .serving(let isFirstServer):
            XCTAssertTrue(isFirstServer)
        default:
            XCTFail()
        }
        XCTAssertFalse(match.team1.deucePlayer!.isServing)
        XCTAssertFalse(match.team1.adPlayer!.isServing)
        XCTAssertFalse(match.team2.adPlayer!.isServing)
        
        match.unrotateServer(previousServerId: "4", wasFirstServer: false)
        
        switch match.team2.adPlayer!.servingState {
        case .serving(let isFirstServer):
            XCTAssertFalse(isFirstServer)
        default:
            XCTFail()
        }
        XCTAssertFalse(match.team1.deucePlayer!.isServing)
        XCTAssertFalse(match.team1.adPlayer!.isServing)
        XCTAssertFalse(match.team2.deucePlayer!.isServing)
        
        match.unrotateServer(previousServerId: "1", wasFirstServer: true)
        
        switch match.team1.deucePlayer!.servingState {
        case .serving(let isFirstServer):
            XCTAssertTrue(isFirstServer)
        default:
            XCTFail()
        }
        XCTAssertFalse(match.team1.adPlayer!.isServing)
        XCTAssertFalse(match.team2.deucePlayer!.isServing)
        XCTAssertFalse(match.team2.adPlayer!.isServing)
        
        match.unrotateServer(previousServerId: "2", wasFirstServer: false)
        
        switch match.team1.adPlayer!.servingState {
        case .serving(let isFirstServer):
            XCTAssertFalse(isFirstServer)
        default:
            XCTFail()
        }
        XCTAssertFalse(match.team1.deucePlayer!.isServing)
        XCTAssertFalse(match.team2.deucePlayer!.isServing)
        XCTAssertFalse(match.team2.adPlayer!.isServing)
    }
    
    func testSinglesPointFinished() {
        var match = LiveMatch(
            team1: LiveMatchTeam(deucePlayer: LiveMatchPlayer(player: Player(id: "1", firstName: "", lastName: "", imageUrl: ""), servingState: .serving())),
            team2: LiveMatchTeam(deucePlayer: LiveMatchPlayer(player: Player(id: "2", firstName: "", lastName: "", imageUrl: "")))
        )
        match.pointFinished(with: LiveMatchShot(playerId: "1", type: .drive, result: .winner, side: .forehand))
        
        XCTAssertEqual(match.team1.currentScore, 1)
        XCTAssertEqual(match.team2.currentScore, 0)
        XCTAssertNil(match.team1.deucePlayer)
        XCTAssertEqual(match.team1.adPlayer?.id, "1")
        XCTAssertNil(match.team2.deucePlayer)
        XCTAssertEqual(match.team2.adPlayer?.id, "2")
        XCTAssertEqual(match.currentServer.id, "1")
        
        match.pointFinished(with: LiveMatchShot(playerId: "1", type: .drop, result: .error, side: .backhand))
        
        XCTAssertEqual(match.team1.currentScore, 1)
        XCTAssertEqual(match.team2.currentScore, 0)
        XCTAssertEqual(match.team1.deucePlayer?.id, "1")
        XCTAssertNil(match.team1.adPlayer)
        XCTAssertEqual(match.team2.deucePlayer?.id, "2")
        XCTAssertNil(match.team2.adPlayer)
        XCTAssertEqual(match.currentServer.id, "2")
        
        match.pointFinished(with: LiveMatchShot(playerId: "1", type: .drop, result: .error, side: .backhand))
        
        XCTAssertEqual(match.team1.currentScore, 1)
        XCTAssertEqual(match.team2.currentScore, 1)
        XCTAssertNil(match.team1.deucePlayer)
        XCTAssertEqual(match.team1.adPlayer?.id, "1")
        XCTAssertNil(match.team2.deucePlayer)
        XCTAssertEqual(match.team2.adPlayer?.id, "2")
        XCTAssertEqual(match.currentServer.id, "2")
        
        match.pointFinished(with: LiveMatchShot(playerId: "1", type: .drop, result: .winner, side: .backhand))
        
        XCTAssertEqual(match.team1.currentScore, 1)
        XCTAssertEqual(match.team2.currentScore, 1)
        XCTAssertNil(match.team1.deucePlayer)
        XCTAssertEqual(match.team1.adPlayer?.id, "1")
        XCTAssertNil(match.team2.deucePlayer)
        XCTAssertEqual(match.team2.adPlayer?.id, "2")
        XCTAssertEqual(match.currentServer.id, "1")
    }
    
    func testDoublesPointFinished() {
        var match = LiveMatch(
            team1: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: Player(id: "1", firstName: "", lastName: "", imageUrl: ""), servingState: .serving(isFirstServer: false)),
                adPlayer: LiveMatchPlayer(player: Player(id: "2", firstName: "", lastName: "", imageUrl: ""))
            ),
            team2: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: Player(id: "3", firstName: "", lastName: "", imageUrl: "")),
                adPlayer: LiveMatchPlayer(player: Player(id: "4", firstName: "", lastName: "", imageUrl: ""))
            )
        )
        
        match.pointFinished(with: LiveMatchShot(playerId: "1", type: .dink, result: .winner, side: .backhand))
        
        XCTAssertEqual(match.team1.currentScore, 1)
        XCTAssertEqual(match.team2.currentScore, 0)
        XCTAssertEqual(match.team1.deucePlayer!.id, "2")
        XCTAssertEqual(match.team1.adPlayer!.id, "1")
        XCTAssertEqual(match.team2.deucePlayer!.id, "3")
        XCTAssertEqual(match.team2.adPlayer!.id, "4")
        XCTAssertEqual(match.currentServer.id, "1")
        
        match.pointFinished(with: LiveMatchShot(playerId: "1", type: .dink, result: .winner, side: .backhand))
        
        XCTAssertEqual(match.team1.currentScore, 2)
        XCTAssertEqual(match.team2.currentScore, 0)
        XCTAssertEqual(match.team1.deucePlayer!.id, "1")
        XCTAssertEqual(match.team1.adPlayer!.id, "2")
        XCTAssertEqual(match.team2.deucePlayer!.id, "3")
        XCTAssertEqual(match.team2.adPlayer!.id, "4")
        XCTAssertEqual(match.currentServer.id, "1")
        
        match.pointFinished(with: LiveMatchShot(playerId: "4", type: .dink, result: .error, side: .backhand))
        
        XCTAssertEqual(match.team1.currentScore, 3)
        XCTAssertEqual(match.team2.currentScore, 0)
        XCTAssertEqual(match.team1.deucePlayer!.id, "2")
        XCTAssertEqual(match.team1.adPlayer!.id, "1")
        XCTAssertEqual(match.team2.deucePlayer!.id, "3")
        XCTAssertEqual(match.team2.adPlayer!.id, "4")
        XCTAssertEqual(match.currentServer.id, "1")
        
        match.pointFinished(with: LiveMatchShot(playerId: "1", type: .dink, result: .error, side: .backhand))
        
        XCTAssertEqual(match.team1.currentScore, 3)
        XCTAssertEqual(match.team2.currentScore, 0)
        XCTAssertEqual(match.team1.deucePlayer!.id, "2")
        XCTAssertEqual(match.team1.adPlayer!.id, "1")
        XCTAssertEqual(match.team2.deucePlayer!.id, "3")
        XCTAssertEqual(match.team2.adPlayer!.id, "4")
        XCTAssertEqual(match.currentServer.id, "3")
        
        match.pointFinished(with: LiveMatchShot(playerId: "4", type: .dink, result: .winner, side: .backhand))
        
        XCTAssertEqual(match.team1.currentScore, 3)
        XCTAssertEqual(match.team2.currentScore, 1)
        XCTAssertEqual(match.team1.deucePlayer!.id, "2")
        XCTAssertEqual(match.team1.adPlayer!.id, "1")
        XCTAssertEqual(match.team2.deucePlayer!.id, "4")
        XCTAssertEqual(match.team2.adPlayer!.id, "3")
        XCTAssertEqual(match.currentServer.id, "3")
    }
    
    func testStartNewGame() {
        var singlesMatch = LiveMatch(
            team1: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: Player(id: "1", firstName: "", lastName: "", imageUrl: ""), servingState: .serving(isFirstServer: false)),
                scores: []
            ),
            team2: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: Player(id: "2", firstName: "", lastName: "", imageUrl: "")),
                scores: []
            )
        )
        
        singlesMatch.startNewGame()
        
        XCTAssertEqual(singlesMatch.team1.scores, [0])
        XCTAssertEqual(singlesMatch.team2.scores, [0])
        
        XCTAssertFalse(singlesMatch.team1.deucePlayer!.isServing)
        XCTAssertFalse(singlesMatch.team2.deucePlayer!.isServing)
        
        var doublesMatch = LiveMatch(
            team1: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: Player(id: "1", firstName: "", lastName: "", imageUrl: ""), servingState: .serving(isFirstServer: false)),
                adPlayer: LiveMatchPlayer(player: Player(id: "2", firstName: "", lastName: "", imageUrl: "")),
                scores: []
            ),
            team2: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: Player(id: "3", firstName: "", lastName: "", imageUrl: "")),
                adPlayer: LiveMatchPlayer(player: Player(id: "4", firstName: "", lastName: "", imageUrl: "")),
                scores: []
            )
        )
        
        doublesMatch.startNewGame()
        
        XCTAssertEqual(doublesMatch.team1.scores, [0])
        XCTAssertEqual(doublesMatch.team2.scores, [0])
        
        XCTAssertFalse(doublesMatch.team1.deucePlayer!.isServing)
        XCTAssertFalse(doublesMatch.team1.adPlayer!.isServing)
        XCTAssertFalse(doublesMatch.team2.deucePlayer!.isServing)
        XCTAssertFalse(doublesMatch.team2.adPlayer!.isServing)
    }
}
