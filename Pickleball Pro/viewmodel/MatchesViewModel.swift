//
//  ViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import Foundation
import Combine

class MatchesViewModel: BaseViewModel<[Match]> {
    override func loginChanged(isLoggedIn: Bool) {
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
        repository.loadMatches {
            switch $0 {
            case .success(let matches):
                self.state = .success(matches)
            case .failure(let error):
                self.state.receivedFailure(.loadMatchesError(afError: error))
            }
        }
    }
    
    func create(match: Match, callback: @escaping (ProError?) -> Void) {
        state.startLoad()
        repository.createMatch(match: match) {
            switch $0 {
            case .success(let newMatch):
                self.state.add(newMatch)
                callback(nil)
            case .failure(let error):
                let proError = ProError.createMatchError(afError: error)
                self.state.receivedFailure(proError)
                callback(proError)
            }
        }
    }
    
    func delete(match: Match, callback: @escaping (ProError?) -> Void = {_ in}) {
        state.startLoad()
        repository.deleteMatch(match: match) {
            switch $0 {
            case .success:
                self.state = .success(self.state.data?.filter { $0.id != match.id } ?? [])
                callback(nil)
            case .failure(let error):
                self.state.receivedFailure(.deleteMatchError(afError: error))
            }
        }
    }
}
