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
    
    func create(player: Player) {
        repository.createPlayer(player: player) {
            self.players.append($0)
        }
    }
    
    func update(player: Player, callback: ((Player) -> Void)? = nil) {
        repository.updatePlayer(player: player) {
            if let index = self.players.firstIndex(where: { $0.id == player.id }) {
                self.players[index] = $0
            }
            callback?($0)
        }
    }
}
