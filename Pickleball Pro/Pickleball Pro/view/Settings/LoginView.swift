//
//  LoginView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/30/21.
//

import SwiftUI
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI
import FirebaseEmailAuthUI
import FirebaseOAuthUI
import AuthenticationServices

struct LoginView: UIViewControllerRepresentable {
    @EnvironmentObject var matchesViewModel: MatchesViewModel
    @EnvironmentObject var playersViewModel: PlayersViewModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        guard let authUI = FUIAuth.defaultAuthUI() else { fatalError("Couldn't load auth UI") }
        authUI.providers = [
            FUIGoogleAuth.init(authUI: authUI),
            FUIFacebookAuth.init(authUI: authUI),
            FUIOAuth.appleAuthProvider(),
            FUIEmailAuth(),
        ]
        return authUI.authViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

class LoginViewDelegate: ObservableObject {
    static let instance = LoginViewDelegate()
    @Published var user: User? = nil
    
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
        }
    }
}
