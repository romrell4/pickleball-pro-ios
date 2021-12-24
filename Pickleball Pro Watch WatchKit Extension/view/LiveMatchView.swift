//
//  LiveMatchView.swift
//  Pickleball-Pro-Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/10/21.
//
import SwiftUI

struct LiveMatchView: View {
    @ObservedObject var viewModel: LiveMatchViewModel
    
    @State private var showingSettings = false
    @State private var statTrackerShowedForPlayer: Player? = nil
    
    private var hSpacing: CGFloat { viewModel.match.isDoubles ? 4 : 0 }
    
    init(match: LiveMatch, closeMatch: @escaping () -> Void) {
        self.viewModel = LiveMatchViewModel(initialMatch: match, closeMatch: closeMatch)
    }
    
    var body: some View {
        HStack(spacing: 10) {
            VStack(spacing: 10) {
                Text("\(viewModel.match.team1.scores.last!)")
                    .font(.title3)
                Text("\(viewModel.match.team2.scores.last!)")
                    .font(.title3)
            }
            #if DEBUG
            .onTapGesture {
                showingSettings = true
            }
            #endif
            GeometryReader { geometry in
                let playerSize = geometry.size.width / 2 - (hSpacing / 2)
                VStack(spacing: 10) {
                    teamView(for: viewModel.match.team1, playerSize: playerSize)
                    teamView(for: viewModel.match.team2, playerSize: playerSize)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        showingSettings = true
                    }
            }
        }
        .sheet(isPresented: $showingSettings) {
            List {
                Button("Start New Game") {
                    viewModel.match.startNewGame()
                    showingSettings = false
                }
                Button("Refresh from Phone") {
                    viewModel.refreshMatch()
                    showingSettings = false
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel.match.needsServer },
            set: { _ in }
        )) {
            SelectServerView(match: $viewModel.match) { player in
                viewModel.match.selectInitialServer(playerId: player.id)
            }
        }
        .sheet(item: $statTrackerShowedForPlayer) { player in
            StatTrackerView(player: player) {
                viewModel.match.pointFinished(with: $0)
            }
        }
    }
    
    private func teamView(for team: LiveMatchTeam, playerSize: CGFloat) -> some View {
        HStack(spacing: hSpacing) {
            if !team.isDoubles {
                Spacer()
            }
            playerView(for: team.deucePlayer, size: playerSize)
            playerView(for: team.adPlayer, size: playerSize)
            if !team.isDoubles {
                Spacer()
            }
        }
    }
    
    @ViewBuilder private func playerView(for player: LiveMatchPlayer?, size: CGFloat) -> some View {
        if let player = player {
            player.imageWithServer(imageSize: size)
                .onTapGesture {
                    statTrackerShowedForPlayer = player.player
                }
        }
    }
}

#if DEBUG
struct LiveMatchView_Previews: PreviewProvider {    
    static var previews: some View {
        LiveMatchView(match: LiveMatch(
            team1: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(
                    player: Player.eric,
                    servingState: .serving(isFirstServer: false)
                ),
                adPlayer: LiveMatchPlayer(player: Player.jessica),
                scores: [10]
            ),
            team2: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: Player.bryan),
                adPlayer: LiveMatchPlayer(player: Player.bob),
                scores: [6]
            )
        )) {
            print("Closed")
        }
    }
}
#endif
