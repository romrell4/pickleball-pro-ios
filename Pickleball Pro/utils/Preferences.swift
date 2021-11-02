//
//  Preferences.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 10/20/21.
//

import Foundation
import SwiftUI

struct PreferenceKeys {
    static var colorScheme = "colorScheme"
    static var autoSwitchSides = "autoSwitchSides"
    static var liveMatchConfirmations = "liveMatchConfirmations"
    static var playerSortDirection = "playerSortDirection"
    static var playerSortOption = "playerSortOption"
}

enum ColorSchemePreference: String, CaseIterable {
    case matchOs
    case dark
    case light
    
    var colorScheme: ColorScheme? {
        switch self {
        case .matchOs: return nil
        case .dark: return .dark
        case .light: return .light
        }
    }
    
    var displayName: String {
        switch self {
        case .matchOs: return "Default"
        case .dark: return "Dark"
        case .light: return "Light"
        }
    }
}
