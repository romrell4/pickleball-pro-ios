//
//  WatchViewModel.swift
//  Pickleball Pro Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/14/21.
//

import Foundation
import SwiftUI
import Combine

class WatchViewModel: ObservableObject, WatchSessionManagerObserver {
    @Published var match: LiveMatch? = nil
    
    private let sessionManager: WatchSessionManager = .instance
    
    init() {
        self.sessionManager.addObserver(self)
    }
    
    deinit {
        self.sessionManager.removeObserver(self)
    }
    
    func onReceivedMatch(match: LiveMatch) {
        self.match = match
    }
    
    func onMatchClosed() {
        self.match = nil
    }

    func refreshMatch() {
        self.sessionManager.sendCommand(command: .refreshMatch)
    }
}
