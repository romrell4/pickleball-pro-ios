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
}

class RepositoryImpl: Repository {
    func loadPlayers(callback: @escaping ([Player]) -> Void) {
        AF.request(
            "\(BASE_URL)/players",
            headers: [
                "x-api-key": "<PUT TOKEN HERE>"
            ]
        ).responseDecodable(of: [Player].self, decoder: DECODER) {
            switch ($0.result) {
            case .success(let players):
                callback(players)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
}

#if DEBUG

class TestRepository: Repository {
    func loadPlayers(callback: @escaping ([Player]) -> Void) {
        callback([Player.eric, Player.jessica, Player.bryan, Player.bob])
    }
}

#endif
