//
//  ContentView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import SwiftUI

struct ContentView: View {
    private var repository = RepositoryImpl()
    
    var body: some View {
        MainTabView()
            .environmentObject(PlayersViewModel(repository: repository))
            .environmentObject(MatchesViewModel(repository: repository))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
