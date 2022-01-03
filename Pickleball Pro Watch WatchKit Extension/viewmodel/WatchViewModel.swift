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
    @Published var match: LiveMatch? = nil //LiveMatch.singles
    
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
