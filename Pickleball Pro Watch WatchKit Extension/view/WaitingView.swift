//
//  WaitingView.swift
//  Pickleball Pro Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/14/21.
//

import SwiftUI

struct WaitingView: View {
    let onRefreshTapped: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("👋")
                    .font(.title)
                Text("Start a live match on your phone to get started!")
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .padding()
                Button("Refresh") {
                    onRefreshTapped()
                }
            }
        }
    }
}

struct WaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingView {
            print("refreshing")
        }
    }
}
