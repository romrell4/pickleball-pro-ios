//
//  MatchStatsView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/4/21.
//

import SwiftUI

struct MatchStatsView: View {
    var match: Match
    
    @State private var gameFilterIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            let filters = ["Match"] + match.scores.indices.map { "Game \($0 + 1)" }
            Picker("Game Filter", selection: $gameFilterIndex) {
                ForEach(filters.indices) { index in
                    Text(filters[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.bottom)
            
            ForEach(match.statGroupings(gameIndex: gameFilterIndex > 0 ? gameFilterIndex - 1 : nil), id: \.self) {
                StatView(statGrouping: $0)
                    .frame(height: 50)
                    .padding(.horizontal, 8)
            }
        }
    }
}

struct MatchStatsView_Previews: PreviewProvider {
    static var previews: some View {
        MatchStatsView(match: Match.doubles)
    }
}
