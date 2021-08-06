//
//  Match.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import Foundation

struct Match {
    let id: String 
    let team1: [Player]
    let team2: [Player]
    let scores: [(Int, Int)]
    let stats: [Stat]
    
    var team1Scores: [Int] {
        scores.map { $0.0 }
    }
    var team2Scores: [Int] {
        scores.map { $0.1 }
    }
    
    func statGroupings(gameIndex: Int? = nil) -> [Stat.Grouping] {
        var eligibleStats = stats
        if let gameIndex = gameIndex {
            eligibleStats = stats.filter { $0.gameIndex == gameIndex }
        }
        let groupedStats = Dictionary(grouping: eligibleStats) { team1.map { $0.id }.contains($0.playerId) }
        let team1Stats = groupedStats[true] ?? []
        let team2Stats = groupedStats[false] ?? []
        
        // TODO: Add more stats based on discussion with Bryan
        
        func grouping(_ label: String, predicate: (Stat) -> Bool) -> Stat.Grouping {
            return Stat.Grouping(label: label, team1Amount: team1Stats.filter(predicate).count, team2Amount: team2Stats.filter(predicate).count)
        }
        
        return [
            grouping("Aces") { $0.type == .ace },
            grouping("Faults") { $0.type == .fault },
            grouping("Forehand Winners") { $0.category == .forehand && $0.result == .winner },
            grouping("Forehand Errors") { $0.category == .forehand && $0.result == .error },
            grouping("Backhand Winners") { $0.category == .backhand && $0.result == .winner },
            grouping("Backhand Errors") { $0.category == .backhand && $0.result == .error },
        ]
    }
}

#if DEBUG

extension Match {
    static let doubles = Match(
        id: "1",
        team1: [Player.eric, Player.jessica],
        team2: [Player.bryan, Player.bob],
        scores: [
            (6, 10),
            (10, 7),
            (4, 10),
        ],
        stats: [
            // 0-0 Eric serving
            Stat.ace(playerId: Player.eric.id),
            // 1-0
            Stat.stat(playerId: Player.eric.id, result: .error, category: .forehand, type: .drive),
            // 1-0 Bryan serving
            Stat.ace(playerId: Player.bryan.id),
            // 1-1
            Stat.stat(playerId: Player.bob.id, result: .winner, category: .forehand, type: .dink),
            // 1-2
            Stat.stat(playerId: Player.jessica.id, result: .error, category: .backhand, type: .drop),
            // 1-3
            Stat.stat(playerId: Player.eric.id, result: .error, category: .backhand, type: .serviceReturn),
            // 1-4
            Stat.stat(playerId: Player.jessica.id, result: .winner, category: .forehand, type: .volley),
            // 1-4 Bob serving
            Stat.stat(playerId: Player.bob.id, result: .error, category: .forehand, type: .volley),
            // 1-4 Jessica serving
            Stat.ace(playerId: Player.jessica.id),
            // 2-4
            Stat.stat(playerId: Player.bob.id, result: .error, category: .forehand, type: .overhead),
            // 3-4
            Stat.stat(playerId: Player.jessica.id, result: .winner, category: .forehand, type: .volley),
            // 4-4
            Stat.stat(playerId: Player.bryan.id, result: .error, category: .backhand, type: .dink),
            // 5-4
            Stat.stat(playerId: Player.jessica.id, result: .winner, category: .backhand, type: .drive),
            // 6-4
            Stat.fault(playerId: Player.jessica.id),
            // 6-4 Eric serving
            Stat.stat(playerId: Player.jessica.id, result: .error, category: .backhand, type: .drop),
            // 6-4 Bryan serving
            Stat.stat(playerId: Player.eric.id, result: .error, category: .backhand, type: .dink),
            // 6-5
            Stat.stat(playerId: Player.bob.id, result: .winner, category: .backhand, type: .volley),
            // 6-6
            Stat.stat(playerId: Player.bob.id, result: .winner, category: .backhand, type: .drive),
            // 6-7
            Stat.stat(playerId: Player.bryan.id, result: .winner, category: .backhand, type: .drop),
            // 6-8
            Stat.ace(playerId: Player.bryan.id),
            // 6-9
            Stat.stat(playerId: Player.eric.id, result: .error, category: .backhand, type: .dink),
            // 6-10
            Stat.stat(playerId: Player.eric.id, result: .error, category: .backhand, type: .dink),
            
            // NEXT SET
            
            // 0-0 Jessica serving
            Stat.stat(playerId: Player.bob.id, gameIndex: 1, result: .error, category: .forehand, type: .volley)
            // 1-0
            // ...
        ]
    )
}

#endif
