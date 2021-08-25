//
//  Repository.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/23/21.
//

import Foundation
import Alamofire

private let BASE_URL = "https://romrell4.github.io/pickleball-pro" //"https://5247f773-d28a-46b6-a312-5fdd5e3c2451.mock.pstmn.io"
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
    func loadPlayers(callback: @escaping ([Player]) -> Void)
    func loadMatches(callback: @escaping ([Match]) -> Void)
}

class RepositoryImpl: Repository {
    func loadPlayers(callback: @escaping ([Player]) -> Void) {
        request(path: "/players", callback: callback)
    }
    
    func loadMatches(callback: @escaping ([Match]) -> Void) {
        let newCallback: ([MatchDto]) -> Void = { matchDtos in
            callback(
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
        }
        request(path: "/matches", callback: newCallback)
    }
    
    func request<T: Decodable>(path: String, callback: @escaping (T) -> Void) {
        AF.request(
            "\(BASE_URL)\(path)",
            headers: [
                "x-api-key": "<PUT TOKEN HERE>"
            ]
        ).responseDecodable(of: T.self, decoder: DECODER) {
            switch ($0.result) {
            case .success(let value):
                callback(value)
            case .failure(let error):
                debugPrint(error)
            }
        }
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
    func loadPlayers(callback: @escaping ([Player]) -> Void) {
        callback([Player.eric, Player.jessica, Player.bryan, Player.bob])
    }
    
    func loadMatches(callback: @escaping ([Match]) -> Void) {
        callback([Match.doubles, Match.singles])
    }
}

#endif