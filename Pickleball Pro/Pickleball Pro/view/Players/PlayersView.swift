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
    @State private var showingAddPlayerSheet = false
    
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
            .toolbar {
                Image(systemName: "plus.circle")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        showingAddPlayerSheet = true
                    }
            }
            .sheet(isPresented: $showingAddPlayerSheet) {
                NavigationView {
                    PlayerDetailsView(player: nil)
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
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
