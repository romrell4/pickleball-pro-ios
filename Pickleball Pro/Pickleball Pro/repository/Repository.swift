//
//  Repository.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/23/21.
//

import Foundation
import Alamofire

private let BASE_URL =
    "https://romrell4.github.io/pickleball-pro-ios"
//    "https://5247f773-d28a-46b6-a312-5fdd5e3c2451.mock.pstmn.io"
private let ENCODER: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
}()
private let DECODER: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

protocol Repository {
    func loadPlayers(callback: @escaping (Result<[Player], AFError>) -> Void)
    func createPlayer(player: Player, callback: @escaping (Result<Player, AFError>) -> Void)
    func deletePlayer(player: Player, callback: @escaping (Result<Player, AFError>) -> Void)
    func updatePlayer(player: Player, callback: @escaping (Result<Player, AFError>) -> Void)
    
    func loadMatches(callback: @escaping (Result<[Match], AFError>) -> Void)
    func createMatch(match: Match, callback: @escaping (Result<Match, AFError>) -> Void)
}

class RepositoryImpl: Repository {
    // Players Endpoints
    
    func loadPlayers(callback: @escaping (Result<[Player], AFError>) -> Void) {
        request(path: "/players", callback: callback)
    }
    
    func createPlayer(player: Player, callback: @escaping (Result<Player, AFError>) -> Void) {
        request(path: "/players", method: .post, body: player, callback: callback)
    }
    
    func deletePlayer(player: Player, callback: @escaping (Result<Player, AFError>) -> Void) {
        request(path: "/players/\(player.id)", method: .delete, callback: callback)
    }
    
    func updatePlayer(player: Player, callback: @escaping (Result<Player, AFError>) -> Void) {
        request(path: "/players/\(player.id)", method: .put, body: player, callback: callback)
    }
    
    // Matches Endpoints
    
    func loadMatches(callback: @escaping (Result<[Match], AFError>) -> Void) {
        let newCallback: (Result<[MatchDto], AFError>) -> Void = {
            switch $0 {
            case .success(let matchDtos):
                callback(
                    .success(
                        matchDtos.map { dto in
                            Match(
                                id: dto.id,
                                date: dto.date,
                                team1: [dto.team1Player1, dto.team1Player2].compactMap { $0 },
                                team2: [dto.team2Player1, dto.team2Player2].compactMap { $0 },
                                scores: dto.scores,
                                stats: dto.stats
                            )
                        }
                    )
                )
            case .failure(let error):
                callback(.failure(error))
            }
        }
        request(path: "/matches", callback: newCallback)
    }
    
    func createMatch(match: Match, callback: @escaping (Result<Match, AFError>) -> Void) {
        request(path: "/matches", method: .post, body: match, callback: callback)
    }
    
    private func request<Res: Decodable>(path: String, method: HTTPMethod = .get, callback: @escaping (Result<Res, AFError>) -> Void) {
        let none: String? = nil
        request(path: path, method: method, body: none, callback: callback)
    }
    
    private func request<Req: Encodable, Res: Decodable>(path: String, method: HTTPMethod = .get, body: Req?, callback: @escaping (Result<Res, AFError>) -> Void) {
        let request = AF.request(
            "\(BASE_URL)\(path)",
            method: method,
            parameters: body,
            encoder: JSONParameterEncoder(encoder: ENCODER),
            headers: [
                "x-api-key": postmanToken,
                "x-mock-response-code": "200",
            ]
        )
        .validate()
        .responseDecodable(of: Res.self, decoder: DECODER) {
            switch ($0.result) {
            case .success: break
            case .failure(let error):
                debugPrint(error)
            }
            callback($0.result)
        }
        
        #if DEBUG
        request.responseJSON { debugPrint($0) }
        #endif
    }
    
    struct MatchDto: Codable {
        let id: String
        let date: Date
        let team1Player1: Player
        let team1Player2: Player?
        let team2Player1: Player
        let team2Player2: Player?
        let scores: [GameScore]
        let stats: [Stat]
    }
}

#if DEBUG

class TestRepository: Repository {
    func loadPlayers(callback: @escaping (Result<[Player], AFError>) -> Void) {
        callback(.success([Player.eric, Player.jessica, Player.bryan, Player.bob]))
    }
    
    func createPlayer(player: Player, callback: @escaping (Result<Player, AFError>) -> Void) {
        let newPlayer = Player(id: UUID().uuidString, firstName: player.firstName, lastName: player.lastName, imageUrl: player.imageUrl, dominantHand: player.dominantHand, level: player.level, phoneNumber: player.phoneNumber, email: player.email, notes: player.notes)
        callback(.success(newPlayer))
    }
    
    func deletePlayer(player: Player, callback: @escaping (Result<Player, AFError>) -> Void) {
        callback(.success(player))
    }
    
    func updatePlayer(player: Player, callback: @escaping (Result<Player, AFError>) -> Void) {
        callback(.success(player))
    }
    
    func loadMatches(callback: @escaping (Result<[Match], AFError>) -> Void) {
        callback(.success([Match.doubles, Match.singles]))
    }
    
    func createMatch(match: Match, callback: @escaping (Result<Match, AFError>) -> Void) {
        let newMatch = Match(id: UUID().uuidString, date: match.date, team1: match.team1, team2: match.team2, scores: match.scores, stats: match.stats)
        callback(.success(newMatch))
    }
}

#endif
