//
//  WatchSessionManager.swift
//  Pickleball Pro Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/14/21.
//

import Foundation
import WatchConnectivity

protocol WatchSessionManagerObserver {
    func onReceivedMatch(match: LiveMatch?)
}

class WatchSessionManager: NSObject, WCSessionDelegate {
    static let instance = WatchSessionManager()
    
    private var observerMap = [String: WatchSessionManagerObserver]()
    private var observers: [WatchSessionManagerObserver] { Array(observerMap.values) }
    func addObserver(_ observer: WatchSessionManagerObserver) {
        observerMap[String(describing: observer)] = observer
    }
    func removeObserver(_ observer: WatchSessionManagerObserver) {
        observerMap.removeValue(forKey: String(describing: observer))
    }
    
    private var session: WCSession = .default
    private var encoder = JSONEncoder()
    private var decoder = JSONDecoder()
    
    var isReachable: Bool { session.isReachable }
    
    private override init() {
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            log("Error activating watch session: \(error)")
        } else {
            log("Successfully activated watch session")
        }
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        log("Session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        log("Session deactivated")
    }
#endif
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handleApplicationContext()
    }
    
    func handleApplicationContext() {
        // If we're receiving the same context we just sent, ignore it
        let newMatchData = session.receivedApplicationContext["match"] as? Data
        guard newMatchData != session.applicationContext["match"] as? Data else {
            log("Filtered out receiving duplicate application context")
            return
        }
        let newMatch = newMatchData.map { try? decoder.decode(LiveMatch.self, from: $0) } ?? nil
        
        log("Received new application context \(String(describing: newMatchData))")
        
        DispatchQueue.main.async {
            self.observers.forEach { $0.onReceivedMatch(match: newMatch) }
        }
    }
    
    func updateMatch(match: LiveMatch?) {
        // If we're about to send the same context we just received or already sent, ignore it
        let newMatchData = match.map { try? encoder.encode($0) } ?? nil
        guard newMatchData != session.applicationContext["match"] as? Data && newMatchData != session.receivedApplicationContext["match"] as? Data else {
            log("Filtered out sending duplicate application context")
            return
        }
        
        var dict = [String: Any]()
        if let data = newMatchData {
            dict["match"] = data
        }
        log("Updating application context with \(dict)")
        try? session.updateApplicationContext(dict)
    }
}

private func log(_ message: Any) {
    print("\(osType()): \(message)")
}

private func osType() -> String {
#if os(watchOS)
    return "watchOS"
#else
    return "iOS"
#endif
}
