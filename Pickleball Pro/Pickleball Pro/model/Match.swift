//
//  Match.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import Foundation

struct Match: Identifiable, Codable, Comparable {
    let id: String
    let date: Date
    var team1: [Player]
    var team2: [Player]
    var scores: [GameScore]
    var stats: [Stat]
    
    enum CodingKeys: String, CodingKey {
        case id = "matchId"
        case date
        case team1
        case team2
        case scores
        case stats
    }
    
    static func < (lhs: Match, rhs: Match) -> Bool {
        lhs.date > rhs.date
    }
    
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
                grouping(type.winnersLabel, hasChildren: type != .serve) { $0.shotType == type && $0.shotResult == .winner },
                grouping(type.errorsLabel, hasChildren: type != .serve) { $0.shotType == type && $0.shotResult == .error },
            ]
        }
    }
    
    static func == (lhs: Match, rhs: Match) -> Bool {
        lhs.id == rhs.id
    }
}

struct GameScore: Codable, Hashable {
    var team1Score: Int = 0
    var team2Score: Int = 0
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
            Stat.stat(playerId: Player.eric.id, shotType: .drive, shotResult: .error, shotSide: .forehand),
            // 1-0 Bryan serving
            Stat.ace(playerId: Player.bryan.id),
            // 1-1
            Stat.stat(playerId: Player.bob.id, shotType: .dink, shotResult: .winner, shotSide: .forehand),
            // 1-2
            Stat.stat(playerId: Player.jessica.id, shotType: .drop, shotResult: .error, shotSide: .backhand),
            // 1-3
            Stat.stat(playerId: Player.eric.id, shotType: .drive, shotResult: .error, shotSide: .backhand),
            // 1-4
            Stat.stat(playerId: Player.jessica.id, shotType: .volley, shotResult: .winner, shotSide: .forehand),
            // 1-4 Bob serving
            Stat.stat(playerId: Player.bob.id, shotType: .volley, shotResult: .error, shotSide: .forehand),
            // 1-4 Jessica serving
            Stat.ace(playerId: Player.jessica.id),
            // 2-4
            Stat.stat(playerId: Player.bob.id, shotType: .overhead, shotResult: .error, shotSide: .forehand),
            // 3-4
            Stat.stat(playerId: Player.jessica.id, shotType: .volley, shotResult: .winner, shotSide: .forehand),
            // 4-4
            Stat.stat(playerId: Player.bryan.id, shotType: .dink, shotResult: .error, shotSide: .backhand),
            // 5-4
            Stat.stat(playerId: Player.jessica.id, shotType: .drive, shotResult: .winner, shotSide: .backhand),
            // 6-4
            Stat.fault(playerId: Player.jessica.id),
            // 6-4 Eric serving
            Stat.stat(playerId: Player.jessica.id, shotType: .drop, shotResult: .error, shotSide: .backhand),
            // 6-4 Bryan serving
            Stat.stat(playerId: Player.eric.id, shotType: .dink, shotResult: .error, shotSide: .backhand),
            // 6-5
            Stat.stat(playerId: Player.bob.id, shotType: .volley, shotResult: .winner, shotSide: .backhand),
            // 6-6
            Stat.stat(playerId: Player.bob.id, shotType: .drive, shotResult: .winner, shotSide: .backhand),
            // 6-7
            Stat.stat(playerId: Player.bryan.id, shotType: .drop, shotResult: .winner, shotSide: .backhand),
            // 6-8
            Stat.ace(playerId: Player.bryan.id),
            // 6-9
            Stat.stat(playerId: Player.eric.id, shotType: .dink, shotResult: .error, shotSide: .backhand),
            // 6-10
            
            // GAME 2
            // 0-0 Jessica serving
            Stat.stat(playerId: Player.bob.id, gameIndex: 1, shotType: .volley, shotResult: .error, shotSide: .forehand),
            // 1-0
            Stat.stat(playerId: Player.bryan.id, gameIndex: 1, shotType: .lob, shotResult: .winner, shotSide: .forehand),
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
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, shotType: .dink, shotResult: .winner, shotSide: .forehand),
            // 2-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, shotType: .dink, shotResult: .winner, shotSide: .forehand),
            // 3-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, shotType: .dink, shotResult: .winner, shotSide: .forehand),
            // 4-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, shotType: .dink, shotResult: .winner, shotSide: .forehand),
            // 5-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, shotType: .dink, shotResult: .winner, shotSide: .forehand),
            // 6-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, shotType: .dink, shotResult: .winner, shotSide: .forehand),
            // 7-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, shotType: .dink, shotResult: .winner, shotSide: .forehand),
            // 8-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, shotType: .dink, shotResult: .winner, shotSide: .forehand),
            // 9-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, shotType: .dink, shotResult: .winner, shotSide: .forehand),
            // 10-7
            
            // GAME 3
            // 0-0 Jessica serving
            Stat.stat(playerId: Player.bob.id, gameIndex: 2, shotType: .volley, shotResult: .error, shotSide: .forehand),
            // 1-0
            Stat.stat(playerId: Player.bryan.id, gameIndex: 2, shotType: .lob, shotResult: .winner, shotSide: .forehand),
            // 1-0 Bob serving
            Stat.ace(playerId: Player.bob.id, gameIndex: 2),
            // 1-1
            Stat.ace(playerId: Player.bob.id, gameIndex: 2),
            // 1-2
            Stat.ace(playerId: Player.bob.id, gameIndex: 2),
            // 1-3
            Stat.ace(playerId: Player.bob.id, gameIndex: 2),
            // 1-4
            Stat.ace(playerId: Player.bob.id, gameIndex: 2),
            // 1-5
            Stat.ace(playerId: Player.bob.id, gameIndex: 2),
            // 1-6
            Stat.ace(playerId: Player.bob.id, gameIndex: 2),
            // 1-7
            Stat.fault(playerId: Player.bob.id, gameIndex: 2),
            // 1-7 Bryan serving
            Stat.fault(playerId: Player.bryan.id, gameIndex: 2),
            // 1-7 Eric serving
            Stat.stat(playerId: Player.jessica.id, gameIndex: 2, shotType: .dink, shotResult: .winner, shotSide: .forehand),
            // 2-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 2, shotType: .dink, shotResult: .winner, shotSide: .forehand),
            // 3-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 2, shotType: .dink, shotResult: .winner, shotSide: .forehand),
            // 4-7
            Stat.stat(playerId: Player.eric.id, gameIndex: 2, shotType: .drive, shotResult: .error, shotSide: .backhand),
            // 4-7 Jessica serving
            Stat.stat(playerId: Player.eric.id, gameIndex: 2, shotType: .drive, shotResult: .error, shotSide: .backhand),
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
