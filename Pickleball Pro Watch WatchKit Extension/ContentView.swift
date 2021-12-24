//
//  ContentView.swift
//  Pickleball Pro Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/14/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = WatchViewModel()
    
    var body: some View {
        if let match = viewModel.match {
            LiveMatchView(match: match) {
                viewModel.match = nil
            }
        } else {
            WaitingView {
                viewModel.refreshMatch()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
