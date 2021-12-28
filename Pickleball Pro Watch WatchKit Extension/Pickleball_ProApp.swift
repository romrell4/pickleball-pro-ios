//
//  Pickleball_ProApp.swift
//  Pickleball Pro Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/14/21.
//

import SwiftUI

@main
struct Pickleball_ProApp: App {
    @WKExtensionDelegateAdaptor var extensionDelegate: ExtensionDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    func applicationDidFinishLaunching() {
        // Initialize the watch session
        let _ = WatchSessionManager.instance
    }
}
