//
//  WatchViewModel.swift
//  Pickleball Pro Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/14/21.
//

import Foundation
import SwiftUI

class WatchViewModel: ObservableObject, WatchSessionManagerDelegate {
    @Published var match: LiveMatch? = nil
    
    private let sessionManager: WatchSessionManager
    
    init() {
        self.sessionManager = WatchSessionManager()
        self.sessionManager.delegate = self
    }
    
    func onReceivedMatch(match: LiveMatch) {
        self.match = match
    }
}
