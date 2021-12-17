//
//  WaitingView.swift
//  Pickleball Pro Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/14/21.
//

import SwiftUI

struct WaitingView: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("👋")
                .font(.title)
            Text("Start a live match on your phone to get started!")
                .multilineTextAlignment(.center)
                .font(.body)
                .padding()
        }
    }
}

struct WaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingView()
    }
}
