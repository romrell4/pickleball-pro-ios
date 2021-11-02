//
//  PlayersViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/13/21.
//

import Foundation

class PlayersViewModel: BaseViewModel<[Player]> {
    override func loginChanged(isLoggedIn: Bool) {
        super.loginChanged(isLoggedIn: isLoggedIn)
        if isLoggedIn {
            load()
        } else {
            state.loggedOut()
        }
    }
    
    func load() {
        guard loginManager.isLoggedIn else {
            state.loggedOut()
            return
        }
        
        state.startLoad()
        repository.loadPlayers {
            switch $0 {
            case .success(let players):
                self.state = .success(players)
            case .failure(let error):
                self.state.receivedFailure(.loadPlayersError(afError: error))
            }
        }
    }
    
    func create(player: Player, callback: @escaping (Player) -> Void) {
        state.startLoad()
        repository.createPlayer(player: player) {
            switch $0 {
            case .success(let newPlayer):
                self.state.add(newPlayer)
                callback(newPlayer)
            case .failure(let error):
                self.state.receivedFailure(.createPlayerError(afError: error))
            }
        }
    }
    
    func update(player: Player, callback: @escaping (Player) -> Void = {_ in}) {
        state.startLoad()
        repository.updatePlayer(player: player) {
            switch $0 {
            case .success(let updatedPlayer):
                self.state = .success(self.state.data?.map { $0.id == player.id ? updatedPlayer : $0 } ?? [])
                callback(updatedPlayer)
            case .failure(let error):
                self.state.receivedFailure(.updatePlayerError(afError: error))
            }
        }
    }
    
    func delete(player: Player, callback: @escaping (ProError?) -> Void = {_ in}) {
        state.startLoad()
        repository.deletePlayer(player: player) {
            switch $0 {
            case .success:
                self.state = .success(self.state.data?.filter { $0.id != player.id } ?? [])
                callback(nil)
            case .failure(let error):
                self.state.receivedFailure(.deletePlayerError(afError: error))
            }
        }
    }
}
