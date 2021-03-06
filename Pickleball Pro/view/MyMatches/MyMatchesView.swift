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
                    let list = List {
                        let matches = matches.sorted()
                        ForEach(matches, id: \.self.id) { match in
                            NavigationLink(destination: MatchDetailView(match: match)) {
                                MatchSummaryView(match: match)
                                    .padding(.vertical, 4)
                            }
                        }.onDelete {
                            let match = matches[$0[$0.startIndex]]
                            viewModel.delete(match: match)
                        }
                    }
                    if #available(iOS 15.0, *) {
                        list.refreshable {
                            viewModel.load()
                        }
                    } else {
                        list
                    }
                }
            }
            .navigationBarTitle("Match History", displayMode: .inline)
        }
    }
}

#if DEBUG
struct MyMatchesView_Previews: PreviewProvider {
    static var previews: some View {
        MyMatchesView()
            .environmentObject(MatchesViewModel(repository: TestRepository(), loginManager: TestLoginManager()))
    }
}
#endif
