//
//  PlayersView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import SwiftUI

struct PlayersView: View {
    @EnvironmentObject var playersViewModel: PlayersViewModel
    
    var body: some View {
        NavigationView {
            List(playersViewModel.players.indices) { index in
                let player = $playersViewModel.players[index]
                NavigationLink(destination: PlayerDetailsView(player: player)) {
                    PlayerSummaryView(player: player.wrappedValue)
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Players")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView().environmentObject(PlayersViewModel(repository: TestRepository()))
    }
}
