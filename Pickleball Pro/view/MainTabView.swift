//
//  MainTabView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import SwiftUI

struct MainTabView: View {
    @State private var tabSelected: Tab = .myMatches
    
    enum Tab {
//#if DEBUG
//        case test
//#endif
        case myMatches
        case stats
        case reportMatch
        case players
        case settings
    }
    
    var body: some View {
        TabView(selection: $tabSelected) {
//#if DEBUG
//            TestView().tabItem {
//                Label("Test", systemImage: "list.bullet")
//            }.tag(Tab.test)
//#endif
            MyMatchesView().tabItem {
                Label("My Matches", systemImage: "list.bullet")
            }.tag(Tab.myMatches)
            MyStatsView().tabItem {
                Label("Stats", systemImage: "chart.bar")
            }.tag(Tab.stats)
            ReportMatchView().tabItem {
                Label("New Match", systemImage: "plus.circle")
            }.tag(Tab.reportMatch).environment(\.currentTab, $tabSelected)
            PlayersView().tabItem {
                Label("Players", systemImage: "person.3")
            }.tag(Tab.players)
            SettingsView().tabItem {
                Label("Settings", systemImage: "gear")
            }.tag(Tab.settings)
        }
    }
}

struct CurrentTabKey: EnvironmentKey {
    static var defaultValue: Binding<MainTabView.Tab> = .constant(.myMatches)
}

extension EnvironmentValues {
    var currentTab: Binding<MainTabView.Tab> {
        get { self[CurrentTabKey.self] }
        set { self[CurrentTabKey.self] = newValue }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
