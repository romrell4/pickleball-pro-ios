//
//  LoginManager.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 11/1/21.
//

import Foundation
import FirebaseAuth

protocol LoginListener {
    func loginChanged(isLoggedIn: Bool)
}

class LoginManager: ObservableObject {
    static let instance = LoginManager()
    @Published var user: User? = nil
    var isLoggedIn: Bool { user != nil }
    private var listeners = [String: LoginListener]()
    
    private init() {
        Auth.auth().addStateDidChangeListener { (_, user) in
#if DEBUG
            if let user = user {
                print("User: \(user)")
                print("Email: \(user.email ?? "no email")")
                print("Name: \(user.displayName ?? "no name")")
                user.getIDToken { token, error in
                    if let token = token {
                        print(token)
                    }
                }
            } else {
                print("No user. Logged out")
            }
#endif
            self.user = user
            self.listeners.forEach {
                $0.1.loginChanged(isLoggedIn: user != nil)
            }
        }
    }
    
    /// Convenience function for adding a listener by using the class name as the tag
    func add(listener: LoginListener) {
        add(listener: listener, for: String(describing: type(of: listener)))
    }
    
    /// This will immediately call the listener with the current value, and then cache it by the tag for further values
    func add(listener: LoginListener, for tag: String) {
        listener.loginChanged(isLoggedIn: isLoggedIn)
        listeners[tag] = listener
    }
    
    /// Convenience function for removing any listener with the tag of the class name
    func remove(listener: LoginListener) {
        remove(tag: String(describing: type(of: listener)))
    }
    
    /// Remove the listener entry for the given tag
    func remove(tag: String) {
        listeners.removeValue(forKey: tag)
    }
}
