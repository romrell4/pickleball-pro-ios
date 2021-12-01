//
//  TestView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/12/21.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        GroupBox {
//            GeometryReader { geometry in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Text("Forehand")
                    WinnerErrorPieChart(data: [.winner: 0.6, .error: 0.4])
                        .frame(height: 200)
                }
                VStack(spacing: 0) {
                    Text("Backhand")
                    WinnerErrorPieChart(data: [.winner: 0.25, .error: 0.75])
                        .frame(height: 200)
                }
            }
//            }
        }.padding(.horizontal)
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View { TestView() }
}
