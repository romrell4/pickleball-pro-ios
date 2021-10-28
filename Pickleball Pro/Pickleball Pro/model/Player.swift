//
//  Player.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import Foundation

struct Player: Identifiable, Codable {
    let id: String
    var firstName: String
    var lastName: String
    var imageUrl: String? = nil
    var dominantHand: Hand? = nil
    var level: Double? = nil
    var phoneNumber: String? = nil
    var email: String? = nil
    var notes: String? = nil
    var isOwner: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "playerId"
        case firstName
        case lastName
        case imageUrl
        case dominantHand
        case level
        case phoneNumber
        case email
        case notes
        case isOwner
    }
    
    enum Hand: String, CaseIterable, Codable {
        case right
        case left
        
        init(from decoder: Decoder) throws {
            let string = try? decoder.singleValueContainer().decode(String.self)
            self = Self.allCases.first { $0.rawValue == string?.lowercased() } ?? .right
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.rawValue.uppercased())
        }
    }
    
    var fullName: String { [firstName, lastName].compactMap { $0 }.joined(separator: " ") }
}

extension Player: PlayerImagable {
    var _firstName: String? { firstName }
    var _lastName: String? { lastName }
}

#if DEBUG

extension Player {
    static let eric = Player(id: "1", firstName: "Eric", lastName: "Romrell", imageUrl: "https://lh3.googleusercontent.com/a-/AOh14GgV7KZOgQ3v3H5SeRnbzCTIAc9N2qM9THqjXrC-IHk=s192-c-rg-br100", dominantHand: .left, level: 4.0, phoneNumber: "503-679-0157", email: "emromrell14@gmail.com", notes: "These are some test notes. He's not THAT great, but he's better than you might expect. I'm going to keep blabbing until this thing wraps, which... it still hasn't... come on!! Wrap!!!", isOwner: true)
    static let jessica = Player(id: "2", firstName: "Jessica", lastName: "Romrell")
    static let bryan = Player(id: "3", firstName: "Bryan", lastName: "Lundberg")
    static let bob = Player(id: "4", firstName: "Bob", lastName: "Crane")
}

#endif
