//
//  PlayersViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/13/21.
//

import Foundation

class PlayersViewModel: ObservableObject {
    @Published var players = [Player]()
    var repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
        load()
    }
    
    func load() {
        repository.loadPlayers {
            self.players = $0
        }
    }
}
