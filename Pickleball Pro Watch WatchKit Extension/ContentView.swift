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
            LiveMatchView(match: match)
        } else {
            WaitingView()
                .onAppear {
                    viewModel.checkForReceivedMatch()
                }
                .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationWillEnterForegroundNotification)) { _ in
                    viewModel.checkForReceivedMatch()
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
