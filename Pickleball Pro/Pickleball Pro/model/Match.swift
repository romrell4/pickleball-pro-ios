//
//  Match.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import Foundation

struct Match: Identifiable, Codable {
    let id: String
    let date: Date
    let team1: [Player]
    let team2: [Player]
    let scores: [GameScore]
    let stats: [Stat]
    
    var team1Scores: [Int] {
        scores.map { $0.team1Score }
    }
    var team2Scores: [Int] {
        scores.map { $0.team2Score }
    }
    
    var isDoubles: Bool { team1.count > 1 && team2.count > 1 }
    
    func statGroupings(gameIndex: Int? = nil, playerIds: [String]? = nil) -> [Stat.Grouping] {
        var eligibleStats = stats
        if let gameIndex = gameIndex {
            eligibleStats = eligibleStats.filter { $0.gameIndex == gameIndex }
        }
        if let playerIds = playerIds {
            eligibleStats = eligibleStats.filter { playerIds.contains($0.playerId) }
        }
        
        var groupedStats: [Bool: [Stat]]
        if let playerIds = playerIds {
            groupedStats = Dictionary(grouping: eligibleStats) { playerIds[0] == $0.playerId }
        } else {
            groupedStats = Dictionary(grouping: eligibleStats) { team1.map { $0.id }.contains($0.playerId) }
        }
        let team1Stats = groupedStats[true] ?? []
        let team2Stats = groupedStats[false] ?? []
        
        func grouping(_ label: String, hasChildren: Bool, predicate: (Stat) -> Bool) -> Stat.Grouping {
            return Stat.Grouping(label: label, team1Stats: team1Stats.filter(predicate), team2Stats: team2Stats.filter(predicate), hasChildren: hasChildren)
        }
        
        return Stat.ShotType.allCases.flatMap { type in
            [
                grouping(type.winnersLabel, hasChildren: type != .serve) { $0.type == type && $0.result == .winner },
                grouping(type.errorsLabel, hasChildren: type != .serve) { $0.type == type && $0.result == .error },
            ]
        }
    }
    
    static func == (lhs: Match, rhs: Match) -> Bool {
        lhs.id == rhs.id
    }
}

struct GameScore: Codable, Hashable {
    let team1Score: Int
    let team2Score: Int
}

#if DEBUG

extension Match {
    static let doubles = Match(
        id: "1",
        date: Date(),
        team1: [Player.eric, Player.jessica],
        team2: [Player.bryan, Player.bob],
        scores: [
            GameScore(team1Score: 6, team2Score: 10),
            GameScore(team1Score: 10, team2Score: 7),
            GameScore(team1Score: 4, team2Score: 10),
        ],
        stats: [
            // GAME 1
            // 0-0 Eric serving
            Stat.ace(playerId: Player.eric.id),
            // 1-0
            Stat.stat(playerId: Player.eric.id, type: .drive, result: .error, side: .forehand),
            // 1-0 Bryan serving
            Stat.ace(playerId: Player.bryan.id),
            // 1-1
            Stat.stat(playerId: Player.bob.id, type: .dink, result: .winner, side: .forehand),
            // 1-2
            Stat.stat(playerId: Player.jessica.id, type: .drop, result: .error, side: .backhand),
            // 1-3
            Stat.stat(playerId: Player.eric.id, type: .drive, result: .error, side: .backhand),
            // 1-4
            Stat.stat(playerId: Player.jessica.id, type: .volley, result: .winner, side: .forehand),
            // 1-4 Bob serving
            Stat.stat(playerId: Player.bob.id, type: .volley, result: .error, side: .forehand),
            // 1-4 Jessica serving
            Stat.ace(playerId: Player.jessica.id),
            // 2-4
            Stat.stat(playerId: Player.bob.id, type: .overhead, result: .error, side: .forehand),
            // 3-4
            Stat.stat(playerId: Player.jessica.id, type: .volley, result: .winner, side: .forehand),
            // 4-4
            Stat.stat(playerId: Player.bryan.id, type: .dink, result: .error, side: .backhand),
            // 5-4
            Stat.stat(playerId: Player.jessica.id, type: .drive, result: .winner, side: .backhand),
            // 6-4
            Stat.fault(playerId: Player.jessica.id),
            // 6-4 Eric serving
            Stat.stat(playerId: Player.jessica.id, type: .drop, result: .error, side: .backhand),
            // 6-4 Bryan serving
            Stat.stat(playerId: Player.eric.id, type: .dink, result: .error, side: .backhand),
            // 6-5
            Stat.stat(playerId: Player.bob.id, type: .volley, result: .winner, side: .backhand),
            // 6-6
            Stat.stat(playerId: Player.bob.id, type: .drive, result: .winner, side: .backhand),
            // 6-7
            Stat.stat(playerId: Player.bryan.id, type: .drop, result: .winner, side: .backhand),
            // 6-8
            Stat.ace(playerId: Player.bryan.id),
            // 6-9
            Stat.stat(playerId: Player.eric.id, type: .dink, result: .error, side: .backhand),
            // 6-10
            
            // GAME 2
            // 0-0 Jessica serving
            Stat.stat(playerId: Player.bob.id, gameIndex: 1, type: .volley, result: .error, side: .forehand),
            // 1-0
            Stat.stat(playerId: Player.bryan.id, gameIndex: 1, type: .lob, result: .winner, side: .forehand),
            // 1-0 Bryan serving
            Stat.ace(playerId: Player.bryan.id, gameIndex: 1),
            // 1-1
            Stat.ace(playerId: Player.bryan.id, gameIndex: 1),
            // 1-2
            Stat.ace(playerId: Player.bryan.id, gameIndex: 1),
            // 1-3
            Stat.ace(playerId: Player.bryan.id, gameIndex: 1),
            // 1-4
            Stat.ace(playerId: Player.bryan.id, gameIndex: 1),
            // 1-5
            Stat.ace(playerId: Player.bryan.id, gameIndex: 1),
            // 1-6
            Stat.ace(playerId: Player.bryan.id, gameIndex: 1),
            // 1-7
            Stat.fault(playerId: Player.bryan.id, gameIndex: 1),
            // 1-7 Bob serving
            Stat.fault(playerId: Player.bob.id, gameIndex: 1),
            // 1-7 Jessica serving
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, type: .dink, result: .winner, side: .forehand),
            // 2-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, type: .dink, result: .winner, side: .forehand),
            // 3-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, type: .dink, result: .winner, side: .forehand),
            // 4-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, type: .dink, result: .winner, side: .forehand),
            // 5-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, type: .dink, result: .winner, side: .forehand),
            // 6-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, type: .dink, result: .winner, side: .forehand),
            // 7-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, type: .dink, result: .winner, side: .forehand),
            // 8-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, type: .dink, result: .winner, side: .forehand),
            // 9-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, type: .dink, result: .winner, side: .forehand),
            // 10-7
            
            // GAME 3
            // 0-0 Jessica serving
            Stat.stat(playerId: Player.bob.id, gameIndex: 2, type: .volley, result: .error, side: .forehand),
            // 1-0
            Stat.stat(playerId: Player.bryan.id, gameIndex: 2, type: .lob, result: .winner, side: .forehand),
            // 1-0 Bryan serving
            Stat.ace(playerId: Player.bryan.id, gameIndex: 2),
            // 1-1
            Stat.ace(playerId: Player.bryan.id, gameIndex: 2),
            // 1-2
            Stat.ace(playerId: Player.bryan.id, gameIndex: 2),
            // 1-3
            Stat.ace(playerId: Player.bryan.id, gameIndex: 2),
            // 1-4
            Stat.ace(playerId: Player.bryan.id, gameIndex: 2),
            // 1-5
            Stat.ace(playerId: Player.bryan.id, gameIndex: 2),
            // 1-6
            Stat.ace(playerId: Player.bryan.id, gameIndex: 2),
            // 1-7
            Stat.fault(playerId: Player.bryan.id, gameIndex: 2),
            // 1-7 Bob serving
            Stat.fault(playerId: Player.bob.id, gameIndex: 2),
            // 1-7 Jessica serving
            Stat.stat(playerId: Player.jessica.id, gameIndex: 2, type: .dink, result: .winner, side: .forehand),
            // 2-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 2, type: .dink, result: .winner, side: .forehand),
            // 3-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 2, type: .dink, result: .winner, side: .forehand),
            // 4-7
            Stat.stat(playerId: Player.eric.id, gameIndex: 2, type: .drive, result: .error, side: .backhand),
            // 4-7 Eric serving
            Stat.stat(playerId: Player.eric.id, gameIndex: 2, type: .drive, result: .error, side: .backhand),
            // 4-7 Bryan serving
            Stat.ace(playerId: Player.bryan.id, gameIndex: 2),
            // 4-8
            Stat.ace(playerId: Player.bryan.id, gameIndex: 2),
            // 4-9
            Stat.ace(playerId: Player.bryan.id, gameIndex: 2),
            // 4-10
        ]
    )
    
    static let singles = Match(
        id: "2",
        date: Date(),
        team1: [Player.eric],
        team2: [Player.bryan],
        scores: [GameScore(team1Score: 10, team2Score: 2)],
        stats: []
    )
}

#endif
