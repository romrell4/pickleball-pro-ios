//
//  PlayersViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/13/21.
//

import Foundation

class PlayersViewModel: ObservableObject {
    @Published var players = [Player]()
    
    func load() {
        players = [
            Player.eric,
            Player.jessica,
            Player.bryan,
            Player.bob,
        ]
    }
}
