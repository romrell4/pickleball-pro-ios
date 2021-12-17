//
//  TestView.swift
//  Pickleball Pro Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/16/21.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        Text("Hello World")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Image(systemName: "gearshape")
                }
            }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
