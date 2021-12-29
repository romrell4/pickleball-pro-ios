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
        handleReceivedApplicationContext()
    }
    
    func handleReceivedApplicationContext() {
        // If we're receiving an outdated version, ignore it
        guard let payload = session.receivedPayload else {
            log("Filtered out invalid payload")
            return
        }
        guard payload.version > (session.sentPayload?.version ?? 0) else {
            log("Filtered out old payload")
            return
        }
        // If we're receiving the same context we just sent, ignore it
        guard payload.match != session.sentPayload?.match else {
            log("Filtered out receiving duplicate payload")
            return
        }
        
        log("Received new payload \(payload)")
        
        DispatchQueue.main.async {
            self.observers.forEach { $0.onReceivedMatch(match: payload.match) }
        }
    }
    
    func updateMatch(match: LiveMatch?) {
        let payload = Payload(version: Date().timeIntervalSince1970, match: match)
        log("Updating payload with \(payload)")
        session.sendPayload(payload)
    }
}

private struct Payload {
    let version: TimeInterval
    let match: LiveMatch?
}

private extension Payload {
    init?(dict: [String: Any]) {
        guard let version = dict["version"] as? Double else { return nil }
        self.version = version
        self.match = (dict["match"] as? Data).map { try? JSONDecoder().decode(LiveMatch.self, from: $0) } ?? nil
    }
    
    var dict: [String: Any] {
        var d: [String: Any] = [
            "version": version
        ]
        if let match = match, let data = try? JSONEncoder().encode(match) {
            d["match"] = data
        }
        return d
    }
}

private extension WCSession {
    var receivedPayload: Payload? {
        Payload(dict: receivedApplicationContext)
    }
    
    var sentPayload: Payload? {
        Payload(dict: applicationContext)
    }
    
    func sendPayload(_ payload: Payload) {
        try? updateApplicationContext(payload.dict)
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
