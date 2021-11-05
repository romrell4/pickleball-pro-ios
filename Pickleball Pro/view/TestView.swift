//
//  TestView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/12/21.
//

import SwiftUI

struct TestView: View {
    @State private var showing: Bool = false

    var body: some View {
        Button("Show") {
            showing = true
        }
        .fullScreenCover(isPresented: $showing) {
            Text("Test")
        }
    }
}

#if DEBUG
struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
            .environmentObject(MatchesViewModel(repository: TestRepository(), loginManager: TestLoginManager()))
    }
}
#endif
