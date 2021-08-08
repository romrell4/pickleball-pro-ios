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
            if (players.count == 1) {
                RoundImageView(url: players[0].imageUrl)
                    .frame(width: 40, height: 40)
            } else {
                StackedRoundImageViews(
                    size: 30,
                    url1: players[0].imageUrl,
                    url2: players[1].imageUrl
                )
                .frame(width: 40, height: 40)
            }
                
            Text(players.map { $0.name }.joined(separator: " & "))
//            VStack {
//            Text(players[0].name)
//                .font(.caption)
//            Text(players[1].name)
//                .font(.caption)
//            }
            Spacer()
            ForEach(scores, id: \.self) { score in
                ScoreNumberView(value: score)
            }
        }
    }
}

struct ScoreNumberView: View {
    let value: Int
    
    var body: some View {
        Text("\(value)")
            .frame(width: 20, height: 20, alignment: .trailing)
            .padding(5)
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        MatchScoreView(match: Match.doubles)
    }
}
