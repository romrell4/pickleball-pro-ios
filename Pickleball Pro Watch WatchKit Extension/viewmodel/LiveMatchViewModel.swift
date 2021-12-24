//
//  LiveMatchViewModel.swift
//  Pickleball Pro Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/19/21.
//

import Foundation
import SwiftUI
import Combine

class LiveMatchViewModel: ObservableObject, WatchSessionManagerObserver {
    @Published var match: LiveMatch
    private var closeMatch: () -> Void
    
    private let sessionManager: WatchSessionManager = .instance
    private var cancellables = Set<AnyCancellable>()
    
    init(initialMatch: LiveMatch, closeMatch: @escaping () -> Void = {}) {
        self.match = initialMatch
        self.closeMatch = closeMatch
        self.sessionManager.addObserver(self)
        
        $match.sink { match in
            self.sessionManager.updateMatch(match: match)
        }
        .store(in: &cancellables)
    }
    
    deinit {
        self.sessionManager.removeObserver(self)
    }
    
    func onMatchClosed() {
        closeMatch()
    }
    
    func refreshMatch() {
        self.sessionManager.sendCommand(command: .refreshMatch)
    }
    
    func onReceivedMatch(match: LiveMatch) {
        self.match = match
    }
}
