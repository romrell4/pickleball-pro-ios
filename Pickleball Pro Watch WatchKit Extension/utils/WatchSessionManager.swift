//
//  WatchSessionManager.swift
//  Pickleball Pro Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/14/21.
//

import Foundation
import WatchConnectivity

protocol WatchSessionManagerDelegate {
    func onReceivedMatch(match: LiveMatch)
}

class WatchSessionManager: NSObject, WCSessionDelegate {
    var delegate: WatchSessionManagerDelegate? = nil
    
    private var session: WCSession
    private var decoder = JSONDecoder()
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Error activating watch session: \(error)")
        } else {
            print("Successfully actived watch session")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        if let match = try? decoder.decode(LiveMatch.self, from: messageData) {
            delegate?.onReceivedMatch(match: match)
        }
    }
}
