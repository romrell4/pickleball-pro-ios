//
//  ContentView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import SwiftUI
import FirebaseAuth

private let repository = RepositoryImpl()
private let loginManager = LoginManager()

struct ContentView: View {
    @AppStorage(PreferenceKeys.colorScheme) private var colorScheme: ColorSchemePreference = .matchOs
    
    var body: some View {
        MainTabView()
            .environmentObject(MatchesViewModel(repository: repository, loginManager: loginManager))
            .environmentObject(PlayersViewModel(repository: repository, loginManager: loginManager))
            .environmentObject(StatsViewModel(repository: repository, loginManager: loginManager))
            .environmentObject(SettingsViewModel(repository: repository, loginManager: loginManager))
            .preferredColorScheme(colorScheme.colorScheme)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
