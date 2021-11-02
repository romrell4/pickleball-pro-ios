//
//  SettingsView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @ObservedObject private var loginManager = LoginManager.instance
    @State private var sheetPresented = false
    @AppStorage(PreferenceKeys.colorScheme) private var colorScheme: ColorSchemePreference = .matchOs
    @AppStorage(PreferenceKeys.autoSwitchSides) private var autoSwitchSides = false
    @AppStorage(PreferenceKeys.liveMatchConfirmations) private var liveMatchConfirmations = true
    
    var body: some View {
        List {
            Section(header: Text("Account")) {
                if let user = loginManager.user {
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
            
            // TODO: Subscription (Required after 5 matches)
            // 1 month ($10)
            // 3 month ($20)
            // 6 month ($35)
            // 12 month ($60)
            
            Section(header: Text("Appearance")) {
                Picker("", selection: $colorScheme) {
                    ForEach(ColorSchemePreference.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                }.pickerStyle(SegmentedPickerStyle())
            }
            ToggleSection(
                isOn: $liveMatchConfirmations,
                title: "Live match confirmations",
                description: "Require confirmation for irreversable actions during a live match, including finishing the match and starting a new game."
            )
            ToggleSection(
                isOn: $autoSwitchSides,
                title: "Switch sides each game",
                description: "When ending a game during a live match, automatically have teams switch sides."
            )
        }
    }
}

private struct ToggleSection: View {
    @Binding var isOn: Bool
    let title: String
    let description: String
    
    var body: some View {
        Section(
            footer: Text(description).font(.caption2)
        ) {
            Toggle(isOn: $isOn) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
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
