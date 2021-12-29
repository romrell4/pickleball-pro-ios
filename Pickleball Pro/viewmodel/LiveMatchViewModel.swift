//
//  LiveMatchViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 12/16/21.
//

import Foundation
import Combine

class LiveMatchViewModel: ObservableObject, WatchSessionManagerObserver {
    // TODO: Move more logic into here?
    @Published var match: LiveMatch
    
    private let sessionManager: WatchSessionManager = .instance
    private var cancellables = Set<AnyCancellable>()
    
    init(initialMatch: LiveMatch) {
        self.match = initialMatch
        self.sessionManager.addObserver(self)
        
        self.$match.sink { match in
            self.sessionManager.updateMatch(match: match)
        }.store(in: &cancellables)
    }
    
    deinit {
        self.sessionManager.removeObserver(self)
    }
    
    func onReceivedMatch(match: LiveMatch?) {
        // Only the phone can finish a match
        guard let match = match else { return }
        
        self.match = match
    }
    
    func closeMatch() {
        self.sessionManager.updateMatch(match: nil)
        
        // Remove the observer, so that if the watch tries to refresh, this won't accidentally send the old match again (since the view model doesn't deinit for some reason)
        self.sessionManager.removeObserver(self)
    }
    
    func serverSelected(playerId: String) {
        match.selectInitialServer(playerId: playerId)
    }
    
    func startNewGame(autoSwitchSides: Bool) {
        match.startNewGame()
        
        if autoSwitchSides {
            match.switchCourtSides()
        }
    }
    
    func checkForReceivedMatch() {
        sessionManager.handleReceivedApplicationContext()
    }
}
