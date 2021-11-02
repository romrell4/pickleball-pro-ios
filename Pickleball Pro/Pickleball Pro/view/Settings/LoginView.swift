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
