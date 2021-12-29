//
//  LiveMatch.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 12/14/21.
//

import Foundation
import SwiftUI

struct LiveMatch: Codable, Equatable, Identifiable {
    var id = UUID().uuidString
    var team1: LiveMatchTeam
    var team2: LiveMatchTeam
    var pointResults: [LiveMatchPointResult] = []
    
    var allPlayers: [LiveMatchPlayer] { team1.players + team2.players }
    
    var isDoubles: Bool { team1.isDoubles && team2.isDoubles }
    
    var currentGameIndex: Int { team1.scores.count - 1 }
    
    // TODO: Make this nullable?
    var currentServer: LiveMatchPlayer { allPlayers.first { $0.isServing }! }
    var needsServer: Bool { !allPlayers.contains { $0.isServing } }
    
    var currentServingTeam: LiveMatchTeam {
        team1.players.contains { $0.id == currentServer.id } ? team1 : team2
    }
    
    func player(for id: String) -> LiveMatchPlayer {
        allPlayers.first { $0.id == id }!
    }
    
    func canUndoLastShot() -> Bool {
        // You can only edit a shot within the same game
        return currentGameIndex == pointResults.last?.gameIndex
    }
    
    mutating func startNewGame() {
        team1.scores.append(0)
        team2.scores.append(0)
        
        setServer(playerId: nil)
    }
    
    mutating func pointFinished(with shot: LiveMatchShot) {
        let playerTeam = team1.players.contains { $0.id == shot.playerId } ? team1 : team2
        
        // If it was a winner by the serving team or an error by the receiving team, add a point to the serving team
        // If it was an error by the serving team or a winner by the receiving team, rotate servers
        let scoreResult: LiveMatchPointResult.ScoreResult
        if (shot.result == .winner && playerTeam.isServing) ||
            (shot.result == .error && !playerTeam.isServing) {
            if team1.isServing {
                team1.earnPoint()
                switchSides(isTeam1Intiating: true)
                scoreResult = .team1Point
            } else {
                team2.earnPoint()
                switchSides(isTeam1Intiating: false)
                scoreResult = .team2Point
            }
        } else {
            guard case .serving(let isFirstServer) = currentServer.servingState else { return }
            scoreResult = .sideout(previousServerId: currentServer.id, wasFirstServer: isFirstServer)
            sideout()
        }
        
        pointResults.append(
            LiveMatchPointResult(
                gameIndex: currentGameIndex,
                shot: shot,
                scoreResult: scoreResult
            )
        )
    }
    
    mutating func sideout() {
        if isDoubles {
            var newServer: (playerId: String?, firstServer: Bool) = (nil, true)
            if case let .serving(isFirstServer) = team1.deucePlayer?.servingState {
                if isFirstServer {
                    newServer = (team1.adPlayer?.id, false)
                } else {
                    newServer = (team2.deucePlayer?.id, true)
                }
            } else if case let .serving(isFirstServer) = team1.adPlayer?.servingState {
                if isFirstServer {
                    newServer = (team1.deucePlayer?.id, false)
                } else {
                    newServer = (team2.deucePlayer?.id, true)
                }
            } else if case let .serving(isFirstServer) = team2.deucePlayer?.servingState {
                if isFirstServer {
                    newServer = (team2.adPlayer?.id, false)
                } else {
                    newServer = (team1.deucePlayer?.id, true)
                }
            } else if case let .serving(isFirstServer) = team2.adPlayer?.servingState {
                if isFirstServer {
                    newServer = (team2.deucePlayer?.id, false)
                } else {
                    newServer = (team1.deucePlayer?.id, true)
                }
            }
            setServer(playerId: newServer.playerId, isFirstServer: newServer.firstServer)
        } else {
            var newServerId: String? = nil
            if team1.deucePlayer?.isServing == true {
                newServerId = team2.deucePlayer?.id
            } else if team1.adPlayer?.isServing == true {
                newServerId = team2.adPlayer?.id
            } else if team2.deucePlayer?.isServing == true {
                newServerId = team1.deucePlayer?.id
            } else if team2.adPlayer?.isServing == true {
                newServerId = team1.adPlayer?.id
            }
            setServer(playerId: newServerId)
        }
    }
    
    mutating func ensureSinglesServerSide() {
        // In singles, when a sideout happens, the server's side is based on their score (deuce for an even score, ad for an odd score)
        if !isDoubles {
            let team = currentServingTeam
            let evenScore = team.currentScore % 2 == 0
            if (evenScore && team.deucePlayer == nil) || (!evenScore && team.adPlayer == nil) {
                switchSides(isTeam1Intiating: team1.isServing)
            }
        }
    }
    
    mutating func unrotateServer(previousServerId: String, wasFirstServer: Bool) {
        setServer(playerId: previousServerId, isFirstServer: wasFirstServer)
    }
    
    mutating func switchSides(isTeam1Intiating: Bool) {
        if isTeam1Intiating {
            team1.switchSides()
            if !isDoubles {
                team2.switchSides()
            }
        } else {
            team2.switchSides()
            if !isDoubles {
                team1.switchSides()
            }
        }
    }
    
    mutating func switchCourtSides() {
        let tempTeam = team1
        self.team1 = team2
        self.team2 = tempTeam
    }
    
    mutating func selectInitialServer(playerId: String) {
        setServer(playerId: playerId, isFirstServer: !isDoubles)
        
        // If they selected a player on the ad side, switch sides
        switch playerId {
        case team1.adPlayer?.id:
            switchSides(isTeam1Intiating: true)
        case team2.adPlayer?.id:
            switchSides(isTeam1Intiating: false)
        default: break
        }
    }
    
    mutating func setServer(playerId: String?, isFirstServer: Bool = true) {
        team1.deucePlayer?.servingState = .notServing
        team1.adPlayer?.servingState = .notServing
        team2.deucePlayer?.servingState = .notServing
        team2.adPlayer?.servingState = .notServing
        switch playerId {
        case team1.deucePlayer?.id:
            team1.deucePlayer?.servingState = .serving(isFirstServer: isFirstServer)
        case team1.adPlayer?.id:
            team1.adPlayer?.servingState = .serving(isFirstServer: isFirstServer)
        case team2.deucePlayer?.id:
            team2.deucePlayer?.servingState = .serving(isFirstServer: isFirstServer)
        case team2.adPlayer?.id:
            team2.adPlayer?.servingState = .serving(isFirstServer: isFirstServer)
        default: break
        }
        
        if playerId != nil {
            ensureSinglesServerSide()
        }
    }
    
    func toMatch() -> Match {
        Match(
            id: "",
            date: Date(),
            team1: team1.players.map { $0.player },
            team2: team2.players.map { $0.player },
            scores: zip(team1.scores, team2.scores)
                .map { GameScore(team1Score: $0.0, team2Score: $0.1) },
            stats: pointResults.compactMap {
                return Stat(
                    playerId: $0.shot.playerId,
                    gameIndex: $0.gameIndex,
                    shotType: $0.shot.type,
                    shotResult: $0.shot.result,
                    shotSide: $0.shot.side
                )
            }
        )
    }
}

struct LiveMatchTeam: Codable, Equatable {
    var deucePlayer: LiveMatchPlayer? = nil
    var adPlayer: LiveMatchPlayer? = nil
    var scores: [Int] = [0]
    
    var players: [LiveMatchPlayer] { [deucePlayer, adPlayer].compactMap { $0 } }
    var isServing: Bool { players.contains { $0.isServing } }
    var isDoubles: Bool { deucePlayer != nil && adPlayer != nil }
    var currentScore: Int { scores.last ?? 0 }
    
    mutating func earnPoint() {
        scores[scores.count - 1] += 1
    }
    
    mutating func losePoint() {
        scores[scores.count - 1] -= 1
    }
    
    mutating func switchSides() {
        let tempPlayer = deucePlayer
        self.deucePlayer = adPlayer
        self.adPlayer = tempPlayer
    }
}

struct LiveMatchPlayer: Codable, Equatable {
    var player: Player
    var servingState: ServingState = .notServing
    
    var id: String { player.id }
    var firstName: String { player.firstName }
    
    var isServing: Bool {
        switch servingState {
        case .notServing: return false
        case .serving(_): return true
        }
    }
    
    enum ServingState: Codable, Equatable {
        case notServing
        case serving(isFirstServer: Bool = true)
        
        var badgeNum: Int? {
            switch self {
            case .notServing: return nil
            case .serving(let isFirstServer): return isFirstServer ? 1 : 2
            }
        }
    }
}

struct LiveMatchPointResult: Codable, Equatable {
    let gameIndex: Int
    let shot: LiveMatchShot
    var scoreResult: ScoreResult
    
    enum ScoreResult: Codable, Equatable {
        case team1Point
        case team2Point
        case sideout(previousServerId: String, wasFirstServer: Bool)
    }
}

struct LiveMatchShot: Codable, Equatable {
    let playerId: String
    let type: Stat.ShotType
    let result: Stat.Result
    let side: Stat.ShotSide?
}

extension LiveMatchPlayer {
    init?(player: Player?, servingState: ServingState = .notServing) {
        if let player = player {
            self.init(player: player, servingState: servingState)
        } else {
            return nil
        }
    }
}
