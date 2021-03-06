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
                Spacer()
                Text("💡").font(.system(size: 80))
                Text("No stats were tracked for this match")
                    .multilineTextAlignment(.center)
                Text("Want to see all your stats? Try using the \"Live Match\" tracking next time you play!")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                MatchStatsView(match: match)
            }
            Spacer()
        }
        .navigationTitle(DATE_FORMAT.string(from: match.date))
    }
}

#if DEBUG
struct MatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MatchDetailView(match: Match.singles)
    }
}
#endif
