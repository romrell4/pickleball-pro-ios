//
//  SelectServerView.swift
//  Pickleball Pro Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/18/21.
//

import SwiftUI

struct SelectServerView: View {
    @Binding var match: LiveMatch
    var onServerTapped: (LiveMatchPlayer) -> Void = {_ in}
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Select the server")
                    .font(.body)
                TeamView(team: $match.team1, isBottom: false, onServerTapped: onServerTapped)
                TeamView(team: $match.team2, isBottom: true, onServerTapped: onServerTapped)
            }
        }
        .navigationBarHidden(true)
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
            VStack(spacing: 0) {
                player.imageWithServer(imageSize: 50)
                Text(player.firstName)
                    .font(.caption)
                    .frame(width: 70)
            }
            .onTapGesture {
                onServerTapped(player)
            }
        } else {
            EmptyView()
        }
    }
}

#if DEBUG
struct SelectServerView_Previews: PreviewProvider {
    private struct Test: View {
        @State var match = LiveMatch(
            team1: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: Player.eric),
                adPlayer: nil //LiveMatchPlayer(player: Player.jessica)
            ),
            team2: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: Player.bryan),
                adPlayer: LiveMatchPlayer(player: Player.bob)
            )
        )
        
        var body: some View {
            SelectServerView(
                match: $match
            ) {
                print($0)
            }
        }
    }
    
    static var previews: some View {
        Test()
    }
}
#endif
