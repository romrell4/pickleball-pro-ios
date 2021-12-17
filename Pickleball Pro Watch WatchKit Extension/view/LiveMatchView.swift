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
                let hSpacing = CGFloat(match.isDoubles ? 4 : 0)
                let playerSize = geometry.size.width / 2 - (hSpacing / 2)
                VStack(spacing: 10) {
                    HStack(spacing: hSpacing) {
                        if !match.isDoubles {
                            Spacer()
                        }
                        if let player = match.team1.deucePlayer?.player {
                            PlayerLink(player: player, size: playerSize).onTapGesture {
                                statTrackerShowedForPlayer = player
                            }
                        }
                        if let player = match.team1.adPlayer?.player {
                            PlayerLink(player: player, size: playerSize).onTapGesture {
                                statTrackerShowedForPlayer = player
                            }
                        }
                        if !match.isDoubles {
                            Spacer()
                        }
                    }
                    HStack(spacing: hSpacing) {
                        if !match.isDoubles {
                            Spacer()
                        }
                        if let player = match.team2.deucePlayer?.player {
                            PlayerLink(player: player, size: playerSize).onTapGesture {
                                statTrackerShowedForPlayer = player
                            }
                        }
                        if let player = match.team2.adPlayer?.player {
                            PlayerLink(player: player, size: playerSize).onTapGesture {
                                statTrackerShowedForPlayer = player
                            }
                        }
                        if !match.isDoubles {
                            Spacer()
                        }
                    }
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
}

private struct PlayerLink : View {
    let player: Player
    let size: CGFloat
    
    var body: some View {
        player.image()
            .frame(width: size, height: size)
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
