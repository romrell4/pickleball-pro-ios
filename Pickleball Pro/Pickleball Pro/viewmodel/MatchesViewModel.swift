//
//  ViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import Foundation
import Combine

class MatchesViewModel: BaseViewModel {
    @Published var state: LoadingState<[Match]> = .idle
    
    override func clear() {
        state = .idle
    }
    
    func load(force: Bool = false) {
        if !force {
            if !state.dataOrEmpty().isEmpty {
                // If we have matches already, no need to reload
                return
            } else if case .loading = state {
                // If we are already loading, don't load again
                return
            }
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
                callback(.createMatchError(afError: error))
            }
        }
    }
}
