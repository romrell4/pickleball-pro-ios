//
//  SettingsViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 11/4/21.
//

import Foundation

class SettingsViewModel: ObservableObject {
    let loginManager: LoginManager
    
    init(loginManager: LoginManager) {
        self.loginManager = loginManager
    }
}
