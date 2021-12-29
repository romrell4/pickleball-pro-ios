//
//  ManualScoreEditView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 11/16/21.
//

import SwiftUI

struct ManualScoreEditView: View {
    @Binding var match: LiveMatch
    let onDoneTapped: () -> Void
    
    var body: some View {
        VStack {
            EnterScoreView(match: $match)
                .padding(.bottom, 20)
            SelectServerView(match: $match) { player in
                guard let currentServer = match.currentServer, case var .serving(isFirstServer) = currentServer.servingState else { return }
                if match.isDoubles && currentServer.id == player.id {
                    isFirstServer.toggle()
                }
                match.setServer(playerId: player.id, isFirstServer: isFirstServer)
            }
                .padding(.bottom)
            Button("Done") {
                onDoneTapped()
            }
        }
    }
}

private struct EnterScoreView: View {
    @Binding var match: LiveMatch
    
    var body: some View {
        VStack {
            Text("Adjust the score")
                .font(.title2)
            ScoreView(label: "Team 1", team: $match.team1) {
                match.ensureSinglesServerSide()
            }
                .padding(.bottom)
            ScoreView(label: "Team 2", team: $match.team2) {
                match.ensureSinglesServerSide()
            }
        }
    }
}

private struct ScoreView: View {
    let label: String
    @Binding var team: LiveMatchTeam
    let pointChanged: () -> Void
    
    var body: some View {
        HStack {
            StackedRoundImageViews(size: 50, player1: team.deucePlayer?.player, player2: team.adPlayer?.player)
                .padding(.trailing, 10)
            GroupBox {
                Text("\(team.currentScore)").frame(width: 22)
            }
            .padding(.trailing, 60)
            Stepper("", value: $team.scores[team.scores.count - 1], in: 0...99) { _ in
                pointChanged()
            }
            .labelsHidden()
        }
    }
}

#if DEBUG
struct ManualScoreEditView_Previews: PreviewProvider {
    private struct Test: View {
        @State var match = LiveMatch(
            team1: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: Player.eric),
                adPlayer: nil, //LiveMatchPlayer(player: Player.jessica),
                scores: [10, 4, 6]
            ),
            team2: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: Player.bryan),
                adPlayer: LiveMatchPlayer(player: Player.bob),
                scores: [2, 10, 3]
            )
        )
        
        var body: some View {
            ManualScoreEditView(
                match: $match
            ) {
                print("Saved")
            }
        }
    }
    
    static var previews: some View {
        ModalView(onDismiss: {}) {
            Test()
        }
            .previewLayout(.sizeThatFits)
    }
}
#endif
