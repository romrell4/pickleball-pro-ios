//
//  MatchSummaryView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/6/21.
//

import SwiftUI

private let DATE_FORMAT: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

struct MatchSummaryView: View {
    let match: Match
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(DATE_FORMAT.string(from: match.date))
                .font(.caption)
            MatchScoreView(match: match)
        }
    }
}

#if DEBUG
struct MatchSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        MatchSummaryView(match: Match.doubles)
    }
}
#endif
