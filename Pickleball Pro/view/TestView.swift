//
//  TestView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/12/21.
//

import SwiftUI

#if DEBUG
struct TestView: View {
    @State private var live = false
    
    var body: some View {
        Button("Go") {
            live = true
        }
        .fullScreenCover(isPresented: $live) {
            LiveMatchView(team1: [Player.eric, Player.jessica], team2: [Player.bryan, Player.bob])
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View { TestView() }
}
#endif
