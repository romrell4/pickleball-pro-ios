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
    let result: Result
    let category: ShotCategory
    let type: ShotType
    
    enum Result {
        case winner
        case error
    }
    
    enum ShotCategory {
        case serve
        case forehand
        case backhand
    }
    
    enum ShotType: String {
        case ace
        case fault
        case drop
        case dink
        case drive
        case serviceReturn
        case volley
        case lob
        case overhead
        
        var singularValue: String {
            let value: String
            switch self {
            case .serviceReturn: value = "return"
            default: value = self.rawValue
            }
            return value.capitalized
        }
        
        var pluralValue: String {
            switch self {
            case .volley: return "Vollies"
            default: return self.singularValue.appending("s")
            }
        }
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
        return Stat(id: id, playerId: playerId, matchId: matchId, gameIndex: gameIndex, result: .winner, category: .serve, type: .ace)
    }
    
    static func fault(id: String = "", playerId: String = "", matchId: String = "", gameIndex: Int = 0) -> Stat {
        return Stat(id: id, playerId: playerId, matchId: matchId, gameIndex: gameIndex, result: .error, category: .serve, type: .fault)
    }
    
    static func stat(
        id: String = "",
        playerId: String = "",
        matchId: String = "",
        gameIndex: Int = 0,
        result: Result = .winner,
        category: ShotCategory = .serve,
        type: ShotType = .ace
    ) -> Stat {
        return Stat(id: id, playerId: playerId, matchId: matchId, gameIndex: gameIndex, result: result, category: category, type: type)
    }
}

#endif
