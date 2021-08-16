//
//  ReportMatchView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import SwiftUI

struct ReportMatchView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                GroupBox {
                    NavigationLink("Track Live Match", destination: LiveMatchView())
                }
                Spacer()
                Text("or")
                Spacer()
                Text("Enter Completed Match").padding(.bottom, 8)
                EnterMatchScoreView()
                Spacer()
            }
            .navigationBarTitle("Report Match")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ReportMatchView_Previews: PreviewProvider {
    static var previews: some View {
        ReportMatchView()
            .environmentObject(PlayersViewModel())
    }
}
