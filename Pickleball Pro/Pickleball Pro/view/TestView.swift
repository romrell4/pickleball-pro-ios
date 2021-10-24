//
//  TestView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/12/21.
//

import SwiftUI

struct TestView: View {
    @State private var empty = false
    var body: some View {
        if empty {
            VStack {}
        } else {
            Button("Make it empty!") {
                self.empty = true
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TestView()
                .navigationTitle("Test")
        }
    }
}
