//
//  ContentView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import SwiftUI
import FirebaseAuth

private let repository = RepositoryImpl()
private let matchesViewModel = MatchesViewModel(repository: repository)
private let playersViewModel = PlayersViewModel(repository: repository)

struct ContentView: View {
    @AppStorage(PreferenceKeys.colorScheme) private var colorScheme: ColorSchemePreference = .matchOs
    
    var body: some View {
        MainTabView()
            .environmentObject(matchesViewModel)
            .environmentObject(playersViewModel)
            .preferredColorScheme(colorScheme.colorScheme)
            .onAppear {
                Auth.auth().addStateDidChangeListener { _, user in
                    if user == nil {
                        matchesViewModel.clear()
                        playersViewModel.clear()
                    }
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
