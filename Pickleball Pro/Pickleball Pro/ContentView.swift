//
//  ContentView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import SwiftUI

struct ContentView: View {
    private var repository = RepositoryImpl()
    @AppStorage(PreferenceKeys.colorScheme) private var colorScheme: ColorSchemePreference = .matchOs
    
    var body: some View {
        MainTabView()
            .environmentObject(PlayersViewModel(repository: repository))
            .environmentObject(MatchesViewModel(repository: repository))
            .preferredColorScheme(colorScheme.colorScheme)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
