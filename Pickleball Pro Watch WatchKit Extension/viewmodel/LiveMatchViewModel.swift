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
    @Published var showingSettings = false
    @Published var statTrackerShowedForPlayer: Player? = nil
    
    private let sessionManager: WatchSessionManager = .instance
    private var cancellables = Set<AnyCancellable>()
    
    init(initialMatch: LiveMatch) {
        self.match = initialMatch
        self.sessionManager.addObserver(self)
        
        $match.sink { match in
            self.sessionManager.updateMatch(match: match)
        }
        .store(in: &cancellables)
    }
    
    deinit {
        self.sessionManager.removeObserver(self)
    }
    
    func checkForReceivedMatch() {
        self.sessionManager.handleReceivedApplicationContext()
        showingSettings = false
    }
    
    func onReceivedMatch(match: LiveMatch?) {
        if let match = match {
            self.match = match
        } else {
            // Dismiss sheets and stuff. The WatchViewModel will take care of exiting the live tracking
            showingSettings = false
            statTrackerShowedForPlayer = nil
        }
    }
    
    func startNewGame() {
        match.startNewGame()
        showingSettings = false
    }
}
