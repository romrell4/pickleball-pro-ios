//
//  MainTabView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MyMatchesView(viewModel: ViewModel()).tabItem {
                Label("Matches", systemImage: "list.bullet")
            }
            MyStatsView().tabItem {
                Label("Stats", systemImage: "chart.bar")
            }
            ReportMatchView().tabItem {
                Label("New Match", systemImage: "plus.circle")
            }
            PlayersView().tabItem {
                Label("Players", systemImage: "person.3")
            }
            SettingsView().tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
