//
//  PlayersView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import SwiftUI

struct PlayersView: View {
    // TODO: Search / Sort
    @EnvironmentObject var viewModel: PlayersViewModel
    @State private var showingAddPlayerSheet = false
    
    var body: some View {
        NavigationView {
            DefaultStateView(state: viewModel.state) { players in
                List {
                    ForEach(players, id: \.id) { player in
                        NavigationLink(destination: PlayerDetailsView(player: player)) {
                            PlayerSummaryView(player: player)
                                .padding(.vertical, 8)
                        }.deleteDisabled(player.isOwner)
                    }
                    .onDelete {
                        let player = players[$0[$0.startIndex]]
                        if !player.isOwner {
                            viewModel.delete(player: player)
                        }
                    }
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
                viewModel.load()
            }
        }
    }
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView()
            .environmentObject(PlayersViewModel(repository: TestRepository()))
    }
}
