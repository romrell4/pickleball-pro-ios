//
//  Pickleball_ProApp.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import SwiftUI
import Firebase
import FBSDKCoreKit

let DEBUG_MODE = true

@main
struct Pickleball_ProApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
}
