//
//  TestView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/12/21.
//

import SwiftUI

struct TestView: View {
    @State private var scores = ["1", "2", "3"]

    var body: some View {
        HStack {
            Spacer()
            ForEach(scores.indices, id: \.self) { index in
                TextField("", text: .proxy($scores[index]))
            }
            Image(systemName: "minus.circle").onTapGesture {
                scores.removeLast()
            }
        }
    }
}

extension Binding where Value: Equatable {
    static func proxy(_ source: Binding<Value>) -> Binding<Value> {
        self.init(
            get: { source.wrappedValue },
            set: { source.wrappedValue = $0 }
        )
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
