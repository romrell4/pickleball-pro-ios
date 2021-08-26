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
        load()
    }
    
    func load() {
        repository.loadMatches {
            self.matches = $0
        }
    }
}
