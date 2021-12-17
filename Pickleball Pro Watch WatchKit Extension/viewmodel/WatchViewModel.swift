//
//  WatchViewModel.swift
//  Pickleball Pro Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/14/21.
//

import Foundation
import SwiftUI
import Combine

class WatchViewModel: ObservableObject, WatchSessionManagerDelegate {
    @Published var match: LiveMatch? = nil
    
    private let sessionManager: WatchSessionManager
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.sessionManager = WatchSessionManager()
        self.sessionManager.delegate = self
        
        $match
            .sink { match in
                if let match = match {
                    self.sessionManager.updateMatch(match: match)
                }
            }
            .store(in: &cancellables)
    }
    
    func onReceivedMatch(match: LiveMatch) {
        self.match = match
    }
}
