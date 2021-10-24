//
//  PlayersViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/13/21.
//

import Foundation

class PlayersViewModel: BaseViewModel {
    @Published var state: LoadingState<[Player]> = .success([])
    
    override func clear() {
        state = .success([])
    }
    
    func load(force: Bool = false) {
        if !force {
            if case let .success(players) = state, !players.isEmpty {
                // If we have players already, no need to reload
                return
            } else if case .loading = state {
                // If we are already loading, don't load again
                return
            }
        }
        state = .loading
        repository.loadPlayers {
            switch $0 {
            case .success(let players):
                self.state = .success(players)
            case .failure(let error):
                self.state = .failed(.loadPlayersError(afError: error))
            }
        }
    }
    
    func create(player: Player, callback: @escaping (Player) -> Void) {
        if case let .success(players) = state {
            state = .loading
            repository.createPlayer(player: player) {
                switch $0 {
                case .success(let newPlayer):
                    self.state = .success(players + [newPlayer])
                    callback(newPlayer)
                case .failure(let error):
                    self.state = .failed(.createPlayerError(afError: error))
                }
            }
        }
    }
    
    func update(player: Player, callback: @escaping (Player) -> Void = {_ in}) {
        if case var .success(players) = state {
            state = .loading
            repository.updatePlayer(player: player) {
                switch $0 {
                case .success(let updatedPlayer):
//                    var newPlayers = players
                    if let index = players.firstIndex(where: { $0.id == player.id }) {
                        players[index] = updatedPlayer
                    }
                    self.state = .success(players)
                    callback(updatedPlayer)
                case .failure(let error):
                    self.state = .failed(.updatePlayerError(afError: error))
                }
            }
        }
    }
    
    func delete(player: Player, callback: @escaping (ProError?) -> Void = {_ in}) {
        if case var .success(players) = state {
            state = .loading
            repository.deletePlayer(player: player) {
                switch $0 {
                case .success:
                    players.removeAll { $0.id == player.id }
                    self.state = .success(players)
                    callback(nil)
                case .failure(let error):
                    self.state = .failed(.deletePlayerError(afError: error))
                }
            }
        }
    }
}
