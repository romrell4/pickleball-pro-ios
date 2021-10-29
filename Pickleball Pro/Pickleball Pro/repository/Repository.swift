//
//  Repository.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/23/21.
//

import Foundation
import Alamofire
import FirebaseAuth

private let BASE_URL =
    "https://bmsq3uf3uc.execute-api.us-west-2.amazonaws.com/prod"
//    "https://romrell4.github.io/pickleball-pro-ios"
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
    func deletePlayer(player: Player, callback: @escaping (Result<Dictionary<String, String>, AFError>) -> Void)
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
    
    func deletePlayer(player: Player, callback: @escaping (Result<Dictionary<String, String>, AFError>) -> Void) {
        request(path: "/players/\(player.id)", method: .delete, callback: callback)
    }
    
    func updatePlayer(player: Player, callback: @escaping (Result<Player, AFError>) -> Void) {
        request(path: "/players/\(player.id)", method: .put, body: player, callback: callback)
    }
    
    // Matches Endpoints
    
    func loadMatches(callback: @escaping (Result<[Match], AFError>) -> Void) {
        request(path: "/matches", callback: callback)
    }
    
    func createMatch(match: Match, callback: @escaping (Result<Match, AFError>) -> Void) {
        request(path: "/matches", method: .post, body: match, callback: callback)
    }
    
    private func request<Res: Decodable>(path: String, method: HTTPMethod = .get, callback: @escaping (Result<Res, AFError>) -> Void) {
        let none: String? = nil
        request(path: path, method: method, body: none, callback: callback)
    }
    
    private func request<Req: Encodable, Res: Decodable>(path: String, method: HTTPMethod = .get, body: Req?, callback: @escaping (Result<Res, AFError>) -> Void) {
        func makeRequest(token: String?) {
            var headers: HTTPHeaders = [
                "x-api-key": postmanToken,
                "x-mock-response-code": "200",
            ]
            if let token = token {
                headers["x-firebase-token"] = token
            }
            let request = AF.request(
                "\(BASE_URL)\(path)",
                method: method,
                parameters: body,
                encoder: JSONParameterEncoder(encoder: ENCODER),
                headers: headers
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
        
        if let user = Auth.auth().currentUser {
            user.getIDToken { token, error in
                if let token = token {
                    makeRequest(token: token)
                } else {
                    print("Error getting ID Token: \(String(describing: error))")
                }
            }
        } else {
            makeRequest(token: nil)
        }
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
    
    func deletePlayer(player: Player, callback: @escaping (Result<Dictionary<String, String>, AFError>) -> Void) {
        callback(.success([:]))
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
