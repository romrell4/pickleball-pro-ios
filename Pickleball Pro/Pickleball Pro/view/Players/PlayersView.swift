//
//  PlayersView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import SwiftUI

struct PlayersView: View {
    @EnvironmentObject var playersViewModel: PlayersViewModel
    
    var body: some View {
        List(playersViewModel.players) { player in
            Text(player.fullName)
        }
    }
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView().environmentObject(PlayersViewModel(repository: TestRepository()))
    }
}
