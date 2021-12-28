//
//  LiveMatchView.swift
//  Pickleball-Pro-Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/10/21.
//
import SwiftUI

struct LiveMatchView: View {
    @ObservedObject var viewModel: LiveMatchViewModel
    
    private var hSpacing: CGFloat { viewModel.match.isDoubles ? 4 : 0 }
    
    init(match: LiveMatch) {
        self.viewModel = LiveMatchViewModel(initialMatch: match)
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
            // The watch previews don't show toolbars, so I can't test the settings. This is a hack to let me test it when I'm debugging
            .onTapGesture {
                viewModel.showingSettings = true
            }
            #endif
            GeometryReader { geometry in
                let playerSize = geometry.size.width / 2 - (hSpacing / 2)
                VStack(spacing: 10) {
                    teamView(for: viewModel.match.team1, playerSize: playerSize, top: true)
                    teamView(for: viewModel.match.team2, playerSize: playerSize, top: false)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        viewModel.showingSettings = true
                    }
            }
        }
        .sheet(isPresented: $viewModel.showingSettings) {
            List {
                Button("Start New Game") {
                    viewModel.startNewGame()
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
        .sheet(item: $viewModel.statTrackerShowedForPlayer) { player in
            StatTrackerView(player: player) {
                viewModel.match.pointFinished(with: $0)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationWillEnterForegroundNotification)) { _ in
            viewModel.refreshMatch()
        }
    }
    
    private func teamView(for team: LiveMatchTeam, playerSize: CGFloat, top: Bool) -> some View {
        HStack(spacing: hSpacing) {
            if !team.isDoubles {
                Spacer()
            }
            playerView(for: top ? team.deucePlayer : team.adPlayer, size: playerSize)
            playerView(for: top ? team.adPlayer : team.deucePlayer, size: playerSize)
            if !team.isDoubles {
                Spacer()
            }
        }
    }
    
    @ViewBuilder private func playerView(for player: LiveMatchPlayer?, size: CGFloat) -> some View {
        if let player = player {
            player.imageWithServer(imageSize: size)
                .onTapGesture {
                    viewModel.statTrackerShowedForPlayer = player.player
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
        ))
    }
}
#endif
