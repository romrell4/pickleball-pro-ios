//
//  TestView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/12/21.
//

import SwiftUI

struct TestView: View {    
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<10, id: \.self) { num in
                    NavigationLink(destination: Text("Hello")) {
                        Text("\(num)")
                    }
                    .deleteDisabled(true)
                }
                .onDelete {
                    print($0)
                }
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
