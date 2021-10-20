//
//  PlayersViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/13/21.
//

import Foundation

class PlayersViewModel: BaseViewModel {
    @Published var players = [Player]()
    
    func load(force: Bool = false) {
        if !force && !players.isEmpty {
            return
        }
        repository.loadPlayers {
            switch $0 {
            case .success(let players):
                self.players = players
            case .failure(let error):
                self.errorHandler.handle(error: .loadPlayersError(afError: error))
            }
        }
    }
    
    func create(player: Player, callback: @escaping (Player) -> Void) {
        repository.createPlayer(player: player) {
            switch $0 {
            case .success(let newPlayer):
                self.players.append(newPlayer)
                callback(newPlayer)
            case .failure(let error):
                self.errorHandler.handle(error: .createPlayerError(afError: error))
            }
        }
    }
    
    func update(player: Player, callback: @escaping (Player) -> Void = {_ in}) {
        repository.updatePlayer(player: player) {
            switch $0 {
            case .success(let updatedPlayer):
                if let index = self.players.firstIndex(where: { $0.id == player.id }) {
                    self.players[index] = updatedPlayer
                }
                callback(updatedPlayer)
            case .failure(let error):
                self.errorHandler.handle(error: .updatePlayerError(afError: error))
            }
        }
    }
    
    func delete(player: Player, callback: @escaping (ProError?) -> Void = {_ in}) {
        repository.deletePlayer(player: player) {
            switch $0 {
            case .success:
                self.players.removeAll { $0.id == player.id }
                callback(nil)
            case .failure(let error):
                self.errorHandler.handle(error: .deletePlayerError(afError: error))
            }
        }
    }
}
