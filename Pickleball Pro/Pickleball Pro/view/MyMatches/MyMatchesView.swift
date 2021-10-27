//
//  MatchHistoryView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/5/21.
//

import SwiftUI

struct MyMatchesView: View {
    @EnvironmentObject var viewModel: MatchesViewModel
    @State private var error: ProError? = nil
    
    var body: some View {
        NavigationView {
            DefaultStateView(state: viewModel.state) { matches in
                if matches.isEmpty {
                    VStack(spacing: 16) {
                        Text("👋")
                            .font(.system(size: 80))
                        Text("You haven't saved any matches yet!")
                            .font(.title3)
                        Text("Tap the \"New Match\" tab to get started.")
                            .font(.callout)
                    }
                    .multilineTextAlignment(.center)
                } else {
                    List(matches, id: \.self.id) { match in
                        NavigationLink(destination: MatchDetailView(match: match)) {
                            MatchSummaryView(match: match)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.load()
            }
        }
    }
}

struct MyMatchesView_Previews: PreviewProvider {
    static var previews: some View {
        MyMatchesView()
            .environmentObject(MatchesViewModel(repository: TestRepository()))
    }
}
