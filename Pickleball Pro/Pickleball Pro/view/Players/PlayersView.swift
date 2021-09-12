//
//  PlayersView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import SwiftUI

struct PlayersView: View {
    // TODO: Search / Sort
    @EnvironmentObject var playersViewModel: PlayersViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(playersViewModel.players, id: \.id) { player in
                    NavigationLink(destination: PlayerDetailsView(player: player)) {
                        PlayerSummaryView(player: player)
                            .padding(.vertical, 8)
                    }
                }
                .onDelete {
                    playersViewModel.delete(player: playersViewModel.players[$0[$0.startIndex]])
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
        PlayersView()
            .environmentObject(PlayersViewModel(repository: TestRepository(), errorHandler: ErrorHandler()))
    }
}
