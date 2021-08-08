//
//  MatchHistoryView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/5/21.
//

import SwiftUI

struct MyMatchesView: View {
    // TODO: Create viewmodel
    let matches: [Match] = [Match.doubles, Match.singles]
    
    var body: some View {
        NavigationView {
            List(matches, id: \.self) { match in
                NavigationLink(destination: MatchDetailView(match: match)) {
                    MatchSummaryView(match: match)
                }
            }
            .navigationTitle("Match History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MatchHistoryListView_Previews: PreviewProvider {
    static var previews: some View {
        MyMatchesView()
    }
}
