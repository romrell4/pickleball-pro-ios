//
//  ViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import Foundation
import Combine

class MatchesViewModel: BaseViewModel {
    @Published var state: LoadingState<[Match]> = .success([])
    
    override func clear() {
        state = .success([])
    }
    
    func load(force: Bool = false) {
        if !force {
            if case let .success(matches) = state, !matches.isEmpty {
                // If we have matches already, no need to reload
                return
            } else if case .loading = state {
                // If we are already loading, don't load again
                return
            }
        }
        state = .loading
        repository.loadMatches {
            switch $0 {
            case .success(let matches):
                self.state = .success(matches)
            case .failure(let error):
                self.state = .failed(.loadMatchesError(afError: error))
            }
        }
    }
    
    func create(match: Match, callback: @escaping () -> Void) {
//        repository.createMatch(match: match) {
//            switch $0 {
//            case .success(let newMatch):
                let newMatch = Match(id: UUID().uuidString, date: match.date, team1: match.team1, team2: match.team2, scores: match.scores, stats: match.stats)
                if case let .success(matches) = state {
                    state = .success(matches + [newMatch])
                }
                callback()
//            case .failure(let error):
//                self.errorHandler.handle(error: .createMatchError(afError: error))
//            }
//        }
    }
}
