//
//  LiveMatchView.swift
//  Pickleball-Pro-Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/10/21.
//
import SwiftUI

struct LiveMatchView: View {
    let match: LiveMatch
    
    var body: some View {
        NavigationView {
            HStack(spacing: 10) {
                VStack(spacing: 10) {
                    Text("\(match.team1.scores.last!)")
                        .font(.title3)
                    Text("\(match.team2.scores.last!)")
                        .font(.title3)
                }
                VStack(spacing: 10) {
                    HStack {
                        PlayerLink(player: match.team1.deucePlayer?.player)
                        PlayerLink(player: match.team1.adPlayer?.player)
                    }
                    HStack {
                        PlayerLink(player: match.team2.deucePlayer?.player)
                        PlayerLink(player: match.team2.adPlayer?.player)
                    }
                }
            }
        }
    }
}

private struct PlayerLink : View {
    private let player: Player
    
    init?(player: Player?) {
        if let player = player {
            self.player = player
        } else {
            return nil
        }
    }
    
    var body: some View {
        NavigationLink(destination: StatTrackerView(player: player, onButtonTap: sendShotToPhone(shot:))) {
            player.image()
        }.buttonStyle(PlainButtonStyle())
    }
    
    func sendShotToPhone(shot: LiveMatchShot) {
        // TODO
        
    }
}

struct LiveMatchView_Previews: PreviewProvider {
    static var previews: some View {
        LiveMatchView(
            match: LiveMatch(
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
        )
    }
}
