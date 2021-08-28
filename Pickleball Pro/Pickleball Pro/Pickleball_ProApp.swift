//
//  Pickleball_ProApp.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import SwiftUI

@main
struct Pickleball_ProApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .withErrorHandling()
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        }
    }
}
