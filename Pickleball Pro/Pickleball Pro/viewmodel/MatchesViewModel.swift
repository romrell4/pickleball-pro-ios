//
//  ViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import Combine

class MatchesViewModel: BaseViewModel {
    @Published var matches = [Match]()
    
    func load(force: Bool = true) {
        if !force && !matches.isEmpty {
            return
        }
        repository.loadMatches {
            switch $0 {
            case .success(let matches):
                self.matches = matches
            case .failure(let error):
                self.errorHandler.handle(error: ProError.loadMatchesError(afError: error))
            }
        }
    }
}
