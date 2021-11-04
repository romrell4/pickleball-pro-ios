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
private let matchesViewModel = MatchesViewModel(repository: repository, loginManager: loginManager)
private let playersViewModel = PlayersViewModel(repository: repository, loginManager: loginManager)
private let statsViewModel = StatsViewModel(repository: repository, loginManager: loginManager)

struct ContentView: View {
    @AppStorage(PreferenceKeys.colorScheme) private var colorScheme: ColorSchemePreference = .matchOs
    
    var body: some View {
        MainTabView()
            .environmentObject(matchesViewModel)
            .environmentObject(playersViewModel)
            .environmentObject(statsViewModel)
            .preferredColorScheme(colorScheme.colorScheme)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
