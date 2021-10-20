//
//  SelectServerModal.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 9/9/21.
//

import SwiftUI

struct SelectServerModal: View {
    @Binding var team1: LiveMatchTeam
    @Binding var team2: LiveMatchTeam
    let onServerTapped: (LiveMatchPlayer) -> Void
    
    var body: some View {
        VStack {
            Text("Who will start serving?")
                .font(.title2)
            TeamView(team: $team1, onServerTapped: onServerTapped)
            TeamView(team: $team2, onServerTapped: onServerTapped)
        }
    }
}

private struct TeamView: View {
    @Binding var team: LiveMatchTeam
    let onServerTapped: (LiveMatchPlayer) -> Void
    
    var body: some View {
        HStack {
            if team.deucePlayer != nil {
                PlayerView(player: $team.deucePlayer, isDoubles: team.isDoubles, onServerTapped: onServerTapped)
            }
            if team.adPlayer != nil {
                PlayerView(player: $team.adPlayer, isDoubles: team.isDoubles, onServerTapped: onServerTapped)
            }
        }
    }
}

private struct PlayerView: View {
    @Binding var player: LiveMatchPlayer?
    let isDoubles: Bool
    let onServerTapped: (LiveMatchPlayer) -> Void
    
    var body: some View {
        if let player = player {
            VStack {
                player.player.image()
                    .frame(width: 50, height: 50)
                Text(player.firstName)
                    .font(.caption)
                    .frame(width: 70)
            }
            .padding(8)
            .onTapGesture {
                self.player?.servingState = .serving(isFirstServer: !isDoubles)
                onServerTapped(player)
            }
        } else {
            EmptyView()
        }
    }
}

struct SelectServerModal_Previews: PreviewProvider {
    private struct Test: View {
        @State var team1 = LiveMatchTeam(
            deucePlayer: LiveMatchPlayer(player: Player.eric),
            adPlayer: LiveMatchPlayer(player: Player.jessica)
        )
        @State var team2 = LiveMatchTeam(
            deucePlayer: LiveMatchPlayer(player: Player.bryan),
            adPlayer: LiveMatchPlayer(player: Player.bob)
        )
        
        var body: some View {
            SelectServerModal(
                team1: $team1,
                team2: $team2
            ) {
                print($0)
            }
        }
    }
    
    static var previews: some View {
        Test()
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.light)
    }
}
