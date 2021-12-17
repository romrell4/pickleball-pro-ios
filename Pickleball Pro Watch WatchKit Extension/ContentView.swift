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
        if viewModel.match != nil {
            LiveMatchView(match: Binding($viewModel.match)!)
        } else {
            WaitingView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
