//
//  PlayersView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import SwiftUI

struct PlayersView: View {
    // TODO: Add swipe to delete
    @EnvironmentObject var playersViewModel: PlayersViewModel
    
    var body: some View {
        NavigationView {
            List(playersViewModel.players, id: \.id) { player in
                NavigationLink(destination: PlayerDetailsView(player: player)) {
                    PlayerSummaryView(player: player)
                        .padding(.vertical, 8)
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Players")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                playersViewModel.load()
            }
        }
    }
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView().environmentObject(PlayersViewModel(repository: TestRepository(), errorHandler: ErrorHandler()))
    }
}
