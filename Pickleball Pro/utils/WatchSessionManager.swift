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
    private var encoder = JSONEncoder()
    private var decoder = JSONDecoder()
    private var lastReceivedMatch: LiveMatch? = nil
    
    var isReachable: Bool { session.isReachable }
    
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
            print("Successfully activated watch session")
        }
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("Session deactivated")
    }
#endif
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        if let match = try? decoder.decode(LiveMatch.self, from: messageData) {
            lastReceivedMatch = match
            DispatchQueue.main.async {
                self.delegate?.onReceivedMatch(match: match)
            }
        }
    }
    
    func updateMatch(match: LiveMatch) {
        if match != lastReceivedMatch, let data = try? encoder.encode(match) {
            session.sendMessageData(data, replyHandler: nil)
        }
    }
}
