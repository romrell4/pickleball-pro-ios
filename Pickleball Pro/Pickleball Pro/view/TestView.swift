//
//  TestView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/12/21.
//

import SwiftUI

struct TestView: View {
    @State private var user: String? = nil
    private lazy var showingLogin: Binding<Bool> = Binding.init(
        get: {
            self.user == nil
        },
        set: {_ in}
    )
    
    var body: some View {
        Text("You can only use this if you log in")
//            .sheet(isPresented: self.showingLogin) {
//                Button("Login") {
//                    user = "Test"
//                }
//            }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
