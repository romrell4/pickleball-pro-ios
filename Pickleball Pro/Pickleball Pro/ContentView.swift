//
//  ContentView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var errorHandler: ErrorHandler
    private var repository = RepositoryImpl()
    
    var body: some View {
        MainTabView()
            .environmentObject(PlayersViewModel(repository: repository, errorHandler: errorHandler))
            .environmentObject(MatchesViewModel(repository: repository, errorHandler: errorHandler))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
