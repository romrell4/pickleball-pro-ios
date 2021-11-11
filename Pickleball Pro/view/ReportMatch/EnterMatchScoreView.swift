//
//  EnterMatchScoreView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/11/21.
//

import SwiftUI

private let MAX_GAMES = 5

struct EnterMatchScoreView: View {
    let team1: [Player]
    let team2: [Player]
    @Binding var scores: [EnterGameScore]
    
    @State private var scoreValidationError = false
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    if team1.count > 1 && team2.count > 1 {
                        StackedRoundImageViews(size: 50, player1: team1[0], player2: team1[1])
                        StackedRoundImageViews(size: 50, player1: team2[0], player2: team2[1])
                    } else {
                        team1[0].image()
                            .frame(width: 50, height: 50)
                        team2[0].image()
                            .frame(width: 50, height: 50)
                    }
                }.padding(.trailing, 10)
                ForEach(scores.indices, id: \.self) { index in
                    GameScoreView(score: .proxy($scores[index]))
                }
                VStack {
                    if scores.count < MAX_GAMES {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                            .onTapGesture {
                                scores.append(EnterGameScore())
                            }
                    }
                    if scores.count > 1 {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                            .onTapGesture {
                                scores.removeLast()
                            }
                    }
                }
                Spacer()
            }.padding(.bottom, 8)
        }
        .padding(.horizontal, 8)
    }
}

private struct GameScoreView: View {
    @Binding var score: EnterGameScore
    
    var body: some View {
        VStack {
            SingleScoreView(textBinding: $score.team1)
            SingleScoreView(textBinding: $score.team2)
        }
    }
    
    struct SingleScoreView: View {
        @Binding var textBinding: String
        
        var body: some View {
            TextField("", text: $textBinding)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(width: 30, height: 30)
                .padding(8)
                .font(.body)
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray))
        }
    }
}

struct EnterGameScore {
    var team1: String = ""
    var team2: String = ""
}

#if DEBUG
struct EnterMatchScoreView_Previews: PreviewProvider {
    static var previews: some View {
        TestWrapper()
    }
    
    struct TestWrapper: View {
        @State private var scores = [EnterGameScore()]
        
        var body: some View {
            EnterMatchScoreView(
                team1: [Player.eric],
                team2: [Player.jessica],
                scores: $scores
            )
        }
    }
}
#endif
