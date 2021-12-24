//
//  WatchSessionManager.swift
//  Pickleball Pro Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/14/21.
//

import Foundation
import WatchConnectivity

protocol WatchSessionManagerObserver {
    func onReceivedMatch(match: LiveMatch)
    func onMatchClosed()
    func refreshMatch()
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
    private var lastReceivedMatch: LiveMatch? = nil
    
    var isReachable: Bool { session.isReachable }
    
    private override init() {
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Error activating watch session: \(error)")
        } else {
            print("Successfully activated watch session")
            observers.forEach { $0.refreshMatch() }
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
                self.observers.forEach { $0.onReceivedMatch(match: match) }
            }
        } else if let command = try? decoder.decode(Command.self, from: messageData) {
            DispatchQueue.main.async {
                switch command {
                case .closeMatch: self.observers.forEach { $0.onMatchClosed() }
                case .refreshMatch: self.observers.forEach { $0.refreshMatch() }
                }
            }
        }
    }
    
    func updateMatch(match: LiveMatch) {
        if match != lastReceivedMatch, let data = try? encoder.encode(match) {
            session.sendMessageData(data, replyHandler: nil)
        }
    }
    
    func sendCommand(command: Command) {
        if let data = try? encoder.encode(command) {
            session.sendMessageData(data, replyHandler: nil)
        }
    }
}

enum Command: Codable {
    case closeMatch
    case refreshMatch
}
