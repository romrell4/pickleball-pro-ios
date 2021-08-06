//
//  Pickleball_ProApp.swift
//  Pickleball Pro WatchKit Extension
//
//  Created by Eric Romrell on 7/17/21.
//

import SwiftUI

@main
struct Pickleball_ProApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
