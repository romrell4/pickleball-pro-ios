//
//  Stat.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/4/21.
//

import Foundation

struct Stat: Hashable, Codable {
    let playerId: String
    let gameIndex: Int
    let type: ShotType
    let result: Result
    var side: ShotSide? = nil
    
    var shot: Shot { Shot(type: type, result: result, side: side) }
    
    struct Shot {
        let type: ShotType
        let result: Result
        let side: ShotSide?
    }
    
    enum ShotType: String, CaseIterable, Codable {
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
        
        var winnersLabel: String {
            switch self {
            case .serve: return "Aces"
            default: return "\(self.rawValue.capitalized) Winners"
            }
        }
        
        var errorsLabel: String {
            switch self {
            case .serve: return "Faults"
            default: return "\(self.rawValue.capitalized) Errors"
            }
        }
    }
    
    enum Result: String, CaseIterable, Codable {
        case winner
        case error
    }
    
    enum ShotSide: String, CaseIterable, Codable {
        case forehand
        case backhand
    }
    
    struct Grouping: Hashable {
        let label: String
        let team1Stats: [Stat]
        let team2Stats: [Stat]
        let hasChildren: Bool
        
        var team1Amount: Int { team1Stats.count }
        var team2Amount: Int { team2Stats.count }
        
        var forehandGrouping: Stat.Grouping {
            Stat.Grouping(
                label: "Forehands",
                team1Stats: team1Stats.filter { $0.side == .forehand },
                team2Stats: team2Stats.filter { $0.side == .forehand },
                hasChildren: false
            )
        }
        var backhandGrouping: Stat.Grouping {
            Stat.Grouping(
                label: "Backhands",
                team1Stats: team1Stats.filter { $0.side == .backhand },
                team2Stats: team2Stats.filter { $0.side == .backhand },
                hasChildren: false
            )
        }
    }
}

#if DEBUG

extension Stat {
    static func ace(playerId: String = "", gameIndex: Int = 0) -> Stat {
        return Stat(playerId: playerId, gameIndex: gameIndex, type: .serve, result: .winner)
    }
    
    static func fault(playerId: String = "", gameIndex: Int = 0) -> Stat {
        return Stat(playerId: playerId, gameIndex: gameIndex, type: .serve, result: .error)
    }
    
    static func stat(
        playerId: String = "",
        gameIndex: Int = 0,
        type: ShotType = .serve,
        result: Result = .winner,
        side: ShotSide? = nil
    ) -> Stat {
        return Stat(playerId: playerId, gameIndex: gameIndex, type: type, result: result, side: side)
    }
}

#endif
