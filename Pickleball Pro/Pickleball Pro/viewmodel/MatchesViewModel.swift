//
//  ViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import Combine

class MatchesViewModel: ObservableObject {
    @Published var matches = [Match]()
    var repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
        loadMatches()
    }
    
    func loadMatches() {
        repository.loadMatches {
            self.matches = $0
        }
    }
}
