//
//  MainTabViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 12/29/21.
//

import Foundation

class MainTabViewModel: ObservableObject, WatchSessionManagerObserver {
    @Published var match: LiveMatch? = nil
    
    private let sessionManager: WatchSessionManager = .instance
    
    init() {
        self.sessionManager.addObserver(self)
    }
    
    deinit {
        self.sessionManager.removeObserver(self)
    }
    
    func onReceivedMatch(match: LiveMatch?) {
        self.match = match
    }

    func checkForReceivedMatch() {
        self.sessionManager.handleReceivedApplicationContext()
    }
}
