//
//  MatchDetailView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/4/21.
//

import SwiftUI

struct MatchDetailView: View {
    let match: Match
    
    var body: some View {
        VStack(spacing: 0) {
            MatchScoreView(match: match).padding()
            MatchStatsView(match: match).padding()
            Spacer()
        }
    }
}

struct MatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MatchDetailView(match: Match.doubles)
    }
}
