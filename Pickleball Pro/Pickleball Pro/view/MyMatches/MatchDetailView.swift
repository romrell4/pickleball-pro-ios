//
//  MatchDetailView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/4/21.
//

import SwiftUI

private let DATE_FORMAT: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

struct MatchDetailView: View {
    let match: Match
    
    var body: some View {
        VStack(spacing: 0) {
            MatchScoreView(match: match).padding()
            
            if match.stats.isEmpty {
                // TODO: Add some extra padding
                Spacer()
                Text("No stats were tracked for this match")
                Text("Want to see all your stats? Try using the \"Live Match\" tracking next time you play!")
                    .font(.caption)
                Spacer()
            } else {
                MatchStatsView(match: match)
            }
            Spacer()
        }
        .navigationTitle(DATE_FORMAT.string(from: match.date))
    }
}

struct MatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MatchDetailView(match: Match.doubles)
    }
}
