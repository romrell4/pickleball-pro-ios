//
//  ScoreView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import SwiftUI

struct MatchScoreView: View {
    let match: Match
    
    var body: some View {
        VStack {
            IndividualScoreView(
                players: match.team1,
                scores: match.team1Scores
            )
            IndividualScoreView(
                players: match.team2,
                scores: match.team2Scores
            )
        }
    }
}

struct IndividualScoreView: View {
    let players: [Player]
    let scores: [Int]
    
    var body: some View {
        HStack {
            StackedRoundImageViews(
                size: 40,
                player1: players[safe: 0],
                player2: players[safe: 1]
            )
                
            Text(players.map { $0.firstName }.joined(separator: " & "))
            Spacer()
            ForEach(scores, id: \.self) { score in
                ScoreNumberView(value: score)
            }
        }
    }
}

private struct ScoreNumberView: View {
    let value: Int
    
    var body: some View {
        Text("\(value)")
            .frame(width: 22, height: 22, alignment: .trailing)
            .padding(5)
    }
}

#if DEBUG
struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        MatchScoreView(match: Match.doubles)
    }
}
#endif
