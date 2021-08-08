//
//  Stat.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/4/21.
//

import Foundation

struct Stat: Hashable {
    let id: String
    let playerId: String
    let matchId: String
    let gameIndex: Int
    let type: ShotType
    let result: Result
    var category: ShotCategory? = nil
    
    enum ShotType: String, CaseIterable {
        case serve
        case drop
        case dink
        case drive
        case volley
        case lob
        case overhead
        
        var trackingOrder: Int {
            switch self {
            case .drop: return 1
            case .dink: return 2
            case .drive: return 3
            case .volley: return 4
            case .lob: return 5
            case .overhead: return 6
            case .serve: return 7
            }
        }
    }
    
    enum Result: CaseIterable {
        case winner
        case error
    }
    
    enum ShotCategory: CaseIterable {
        case forehand
        case backhand
    }
    
    struct Grouping: Hashable {
        let label: String
        let team1Amount: Int
        let team2Amount: Int
    }
}

#if DEBUG

extension Stat {
    static func ace(id: String = "", playerId: String = "", matchId: String = "", gameIndex: Int = 0) -> Stat {
        return Stat(id: id, playerId: playerId, matchId: matchId, gameIndex: gameIndex, type: .serve, result: .winner)
    }
    
    static func fault(id: String = "", playerId: String = "", matchId: String = "", gameIndex: Int = 0) -> Stat {
        return Stat(id: id, playerId: playerId, matchId: matchId, gameIndex: gameIndex, type: .serve, result: .error)
    }
    
    static func stat(
        id: String = "",
        playerId: String = "",
        matchId: String = "",
        gameIndex: Int = 0,
        type: ShotType = .serve,
        result: Result = .winner,
        category: ShotCategory? = nil
    ) -> Stat {
        return Stat(id: id, playerId: playerId, matchId: matchId, gameIndex: gameIndex, type: type, result: result, category: category)
    }
}

#endif
