//
//  LiveMatchView.swift
//  Pickleball-Pro-Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/10/21.
//
import SwiftUI

struct LiveMatchView: View {
    @Binding var match: LiveMatch
    
    @State private var showingSettings = false
    @State private var statTrackerShowedForPlayer: Player? = nil
    
    private var hSpacing: CGFloat { match.isDoubles ? 4 : 0 }
    
    var body: some View {
        HStack(spacing: 10) {
            VStack(spacing: 10) {
                Text("\(match.team1.scores.last!)")
                    .font(.title3)
                Text("\(match.team2.scores.last!)")
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
                    teamView(for: match.team1, playerSize: playerSize)
                    teamView(for: match.team2, playerSize: playerSize)
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
                    // TODO: Deal with selecting new server
                    match.startNewGame()
                    showingSettings = false
                }
                // TODO: Add other necessary options
            }
        }
        .sheet(item: $statTrackerShowedForPlayer) { player in
            StatTrackerView(player: player) {
                match.pointFinished(with: $0)
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
            let image = player.player.image()
                .frame(width: size, height: size)
                .onTapGesture {
                    statTrackerShowedForPlayer = player.player
                }
            if let count = player.servingState.badgeNum {
                image.overlay(
                    ZStack(alignment: .topTrailing) {
                        Color.clear
                        Text(String(count))
                            .foregroundColor(.black)
                            .frame(width: 20, height: 20)
                            .background(Color.yellow)
                            .clipShape(Circle())
                            .overlay(Circle().strokeBorder(.black))
                    }
                )
            } else {
                image
            }
        }
    }
}

#if DEBUG
struct LiveMatchView_Previews: PreviewProvider {
    private struct Test: View {
        @State var match = LiveMatch(
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
        )
        
        var body: some View {
            LiveMatchView(match: $match)
        }
    }
    
    static var previews: some View {
        Test()
    }
}
#endif
