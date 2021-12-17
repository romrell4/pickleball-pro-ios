//
//  LiveMatchViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 12/16/21.
//

import Foundation
import Combine

class LiveMatchViewModel: ObservableObject, WatchSessionManagerDelegate {
    // TODO: Move more logic into here?
    @Published var match: LiveMatch
    
    private let sessionManager: WatchSessionManager
    private var cancellables = Set<AnyCancellable>()
    
    init(initialMatch: LiveMatch) {
        self.match = initialMatch
        self.sessionManager = WatchSessionManager()
        self.sessionManager.delegate = self
        
        self.$match.sink {
            self.sessionManager.updateMatch(match: $0)
        }
        .store(in: &cancellables)
    }
    
    func onReceivedMatch(match: LiveMatch) {
        self.match = match
    }
}
