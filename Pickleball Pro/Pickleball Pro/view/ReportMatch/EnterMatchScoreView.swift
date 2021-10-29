//
//  EnterMatchScoreView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/11/21.
//

import SwiftUI

private let MAX_GAMES = 5

struct EnterMatchScoreView: View {
    // TODO: Put players' icons before scores
    // TODO: Figure out scrolling and next buttons between text fields
    @Binding var scores: [EnterGameScore]
    
    @State private var scoreValidationError = false
    
    var body: some View {
        VStack {
            HStack {
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

struct EnterMatchScoreView_Previews: PreviewProvider {
    static var previews: some View {
        TestWrapper()
    }
    
    struct TestWrapper: View {
        @State private var scores = [EnterGameScore()]
        
        var body: some View {
            EnterMatchScoreView(scores: $scores)
        }
    }
}
