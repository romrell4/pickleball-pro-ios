//
//  TestView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/12/21.
//

import SwiftUI

struct TestView: View {
    @State private var text = ""
    @State private var shouldNavigate = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("", text: $text).border(Color.black)
                EmbeddedView(shouldNavigate: $shouldNavigate)
                NavigationLink(destination: Text(text), isActive: $shouldNavigate) { EmptyView() }
            }
            .navigationBarTitle("Test")
        }
    }
}

struct EmbeddedView: View {
    @Binding var shouldNavigate: Bool
    
    var body: some View {
        Button("Save") {
            shouldNavigate = true
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
