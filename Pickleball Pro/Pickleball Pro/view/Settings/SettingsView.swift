//
//  SettingsView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @ObservedObject private var loginDelegate = LoginViewDelegate.instance
    @State private var sheetPresented = false
    private var loggedIn: Bool { loginDelegate.user != nil }
    
    var body: some View {
        VStack {
            if let user = loginDelegate.user {
                Text("Logged in as '\(String(describing: user.displayName))'")
            } else {
                Text("Not logged in")
            }
            Button(loggedIn ? "Logout" : "Login") {
                if loggedIn {
                    try? Auth.auth().signOut()
                }
                sheetPresented = !loggedIn
            }
        }
        .sheet(isPresented: $sheetPresented) {
            LoginView()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
