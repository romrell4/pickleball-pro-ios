//
//  Stat.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/4/21.
//

import Foundation

struct Stat: Hashable, Codable {
    let matchId: String
    let playerId: String
    let gameIndex: Int
    let shotType: ShotType
    let shotResult: Result
    var shotSide: ShotSide? = nil
    
    var shot: Shot { Shot(type: shotType, result: shotResult, side: shotSide) }
    
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
        
        init(from decoder: Decoder) throws {
            let string = try? decoder.singleValueContainer().decode(String.self)
            self = Self.allCases.first { $0.rawValue == string?.lowercased() } ?? .serve
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.rawValue.uppercased())
        }
        
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
        
        init(from decoder: Decoder) throws {
            let string = try? decoder.singleValueContainer().decode(String.self)
            self = Self.allCases.first { $0.rawValue == string?.lowercased() } ?? .winner
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.rawValue.uppercased())
        }
    }
    
    enum ShotSide: String, CaseIterable, Codable {
        case forehand
        case backhand
        
        init(from decoder: Decoder) throws {
            let string = try? decoder.singleValueContainer().decode(String.self)
            self = Self.allCases.first { $0.rawValue == string?.lowercased() } ?? .forehand
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.rawValue.uppercased())
        }
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
                team1Stats: team1Stats.filter { $0.shotSide == .forehand },
                team2Stats: team2Stats.filter { $0.shotSide == .forehand },
                hasChildren: false
            )
        }
        var backhandGrouping: Stat.Grouping {
            Stat.Grouping(
                label: "Backhands",
                team1Stats: team1Stats.filter { $0.shotSide == .backhand },
                team2Stats: team2Stats.filter { $0.shotSide == .backhand },
                hasChildren: false
            )
        }
    }
}

#if DEBUG

extension Stat {
    static func ace(matchId: String = "", playerId: String = "", gameIndex: Int = 0) -> Stat {
        return Stat(matchId: matchId, playerId: playerId, gameIndex: gameIndex, shotType: .serve, shotResult: .winner)
    }
    
    static func fault(matchId: String = "", playerId: String = "", gameIndex: Int = 0) -> Stat {
        return Stat(matchId: matchId, playerId: playerId, gameIndex: gameIndex, shotType: .serve, shotResult: .error)
    }
    
    static func stat(
        matchId: String = "",
        playerId: String = "",
        gameIndex: Int = 0,
        shotType: ShotType = .serve,
        shotResult: Result = .winner,
        shotSide: ShotSide? = nil
    ) -> Stat {
        return Stat(matchId: matchId, playerId: playerId, gameIndex: gameIndex, shotType: shotType, shotResult: shotResult, shotSide: shotSide)
    }
}

#endif
