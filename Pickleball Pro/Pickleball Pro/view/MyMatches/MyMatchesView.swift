//
//  MatchHistoryView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/5/21.
//

import SwiftUI

struct MyMatchesView: View {
    // TODO: Create viewmodel
    @ObservedObject
    var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.matches, id: \.self.id) { match in
                NavigationLink(destination: MatchDetailView(match: match)) {
                    MatchSummaryView(match: match)
                }
            }
            .navigationTitle("Match History")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadMatches()
            }
        }
    }
}

struct MatchHistoryListView_Previews: PreviewProvider {
    static var previews: some View {
        MyMatchesView(viewModel: ViewModel())
    }
}
