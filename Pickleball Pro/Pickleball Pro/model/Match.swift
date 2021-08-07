//
//  Match.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import Foundation

struct Match: Hashable {
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
    
    static func == (lhs: Match, rhs: Match) -> Bool {
        lhs.id == rhs.id
    }
}

struct GameScore: Hashable {
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
            
            // GAME 2
            // 0-0 Jessica serving
            Stat.stat(playerId: Player.bob.id, gameIndex: 1, result: .error, category: .forehand, type: .volley),
            // 1-0
            Stat.stat(playerId: Player.bryan.id, gameIndex: 1, result: .winner, category: .forehand, type: .lob),
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
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, result: .winner, category: .forehand, type: .dink),
            // 2-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, result: .winner, category: .forehand, type: .dink),
            // 3-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, result: .winner, category: .forehand, type: .dink),
            // 4-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, result: .winner, category: .forehand, type: .dink),
            // 5-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, result: .winner, category: .forehand, type: .dink),
            // 6-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, result: .winner, category: .forehand, type: .dink),
            // 7-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, result: .winner, category: .forehand, type: .dink),
            // 8-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, result: .winner, category: .forehand, type: .dink),
            // 9-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 1, result: .winner, category: .forehand, type: .dink),
            // 10-7
            
            // GAME 3
            // 0-0 Jessica serving
            Stat.stat(playerId: Player.bob.id, gameIndex: 2, result: .error, category: .forehand, type: .volley),
            // 1-0
            Stat.stat(playerId: Player.bryan.id, gameIndex: 2, result: .winner, category: .forehand, type: .lob),
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
            Stat.stat(playerId: Player.jessica.id, gameIndex: 2, result: .winner, category: .forehand, type: .dink),
            // 2-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 2, result: .winner, category: .forehand, type: .dink),
            // 3-7
            Stat.stat(playerId: Player.jessica.id, gameIndex: 2, result: .winner, category: .forehand, type: .dink),
            // 4-7
            Stat.stat(playerId: Player.eric.id, gameIndex: 2, result: .error, category: .backhand, type: .drive),
            // 4-7 Eric serving
            Stat.stat(playerId: Player.eric.id, gameIndex: 2, result: .error, category: .backhand, type: .drive),
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
