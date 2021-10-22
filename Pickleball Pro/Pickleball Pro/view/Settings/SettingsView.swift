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
    @AppStorage(PreferenceKeys.colorScheme) private var colorScheme: ColorSchemePreference = .matchOs
    @AppStorage(PreferenceKeys.autoSwitchSides) private var autoSwitchSides = false
    
    var body: some View {
        List {
            Section(header: Text("Account")) {
                if let user = loginDelegate.user {
                    if let name = user.displayName {
                        Text("Logged in as \(name)")
                    } else {
                        Text("Logged in")
                    }
                    Button("Log out") {
                        try? Auth.auth().signOut()
                    }
                } else {
                    Text("Not logged in")
                    Button("Log in") {
                        sheetPresented = true
                    }
                    .sheet(isPresented: $sheetPresented) {
                        LoginView()
                    }
                }
            }
            Section(header: Text("Appearance")) {
                Picker("", selection: $colorScheme) {
                    ForEach(ColorSchemePreference.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                }.pickerStyle(SegmentedPickerStyle())
            }
            Section(
                footer: Text("When ending a game during a live match, automatically have teams switch sides.").font(.caption2)
            ) {
                Toggle(isOn: $autoSwitchSides) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Switch sides each game")
                        
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
