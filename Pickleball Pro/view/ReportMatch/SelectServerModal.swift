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
            TeamView(team: $team1, isBottom: false, onServerTapped: onServerTapped)
            TeamView(team: $team2, isBottom: true, onServerTapped: onServerTapped)
        }
    }
}

private struct TeamView: View {
    @Binding var team: LiveMatchTeam
    let isBottom: Bool
    let onServerTapped: (LiveMatchPlayer) -> Void
    
    var deucePlayer: PlayerView? {
        if team.deucePlayer != nil {
            return PlayerView(player: $team.deucePlayer, isDoubles: team.isDoubles, onServerTapped: onServerTapped)
        } else {
            return nil
        }
    }
    
    var adPlayer: PlayerView? {
        if team.adPlayer != nil {
            return PlayerView(player: $team.adPlayer, isDoubles: team.isDoubles, onServerTapped: onServerTapped)
        } else {
            return nil
        }
    }
    
    var switchImage: some View {
        Image(systemName: "arrow.left.arrow.right")
            .resizable()
            .foregroundColor(.blue)
            .frame(width: 20, height: 20)
            .onTapGesture {
                team.switchSides()
            }
    }
    
    var body: some View {
        HStack {
            if !isBottom {
                deucePlayer
                if team.isDoubles {
                    switchImage
                }
                adPlayer
            } else {
                adPlayer
                if team.isDoubles {
                    switchImage
                }
                deucePlayer
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

#if DEBUG
struct SelectServerModal_Previews: PreviewProvider {
    private struct Test: View {
        @State var team1 = LiveMatchTeam(
            deucePlayer: LiveMatchPlayer(player: Player.eric),
            adPlayer: nil //LiveMatchPlayer(player: Player.jessica)
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
#endif
