//
//  SettingsViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 11/4/21.
//

import Foundation

class SettingsViewModel: BaseViewModel<User> {
    override func loginChanged(isLoggedIn: Bool) {
        if isLoggedIn, let user = loginManager.user {
            state = .success(user)
        } else {
            state.loggedOut()
        }
    }
}
