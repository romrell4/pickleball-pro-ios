//
//  ViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import Foundation
import Combine

class MatchesViewModel: BaseViewModel {
    @Published var matches = [Match]()
    
    func load(force: Bool = false) {
        if !force && !matches.isEmpty {
            return
        }
        // TODO: Why is this loading twice on startup?
        repository.loadMatches {
            switch $0 {
            case .success(let matches):
                self.matches = matches
            case .failure(let error):
                self.errorHandler.handle(error: .loadMatchesError(afError: error))
            }
        }
    }
    
    func create(match: Match, callback: @escaping () -> Void) {
//        repository.createMatch(match: match) {
//            switch $0 {
//            case .success(let newMatch):
                let newMatch = Match(id: UUID().uuidString, date: match.date, team1: match.team1, team2: match.team2, scores: match.scores, stats: match.stats)
                self.matches.append(newMatch)
                callback()
//            case .failure(let error):
//                self.errorHandler.handle(error: .createMatchError(afError: error))
//            }
//        }
    }
}
