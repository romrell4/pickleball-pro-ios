//
//  SelectPlayersView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/19/21.
//

import SwiftUI

private let MAX_PLAYER_PAIRS = 2
private let PLAYER_ICON_SIZE: CGFloat = 50
private let ADD_BUTTON_SIZE: CGFloat = 30

struct SelectPlayersView: View {
    @Binding var players: [EnterPlayers]
    
    var body: some View {
        HStack(spacing: 15) {
            VStack {
                Text("Team 1:")
                    .font(.title2)
                    .padding(.bottom, 20)
                Text("Team 2:")
                    .font(.title2)
            }
            ForEach(players.indices, id: \.self) { index in
                EnterPlayersView(players: .proxy($players[index]))
            }
            let canAdd = players.count < MAX_PLAYER_PAIRS
            Image(systemName: canAdd ? "plus.circle.fill" : "minus.circle.fill")
                .resizable()
                .frame(width: ADD_BUTTON_SIZE, height: ADD_BUTTON_SIZE)
                .foregroundColor(.blue)
                .onTapGesture {
                    if canAdd {
                        players.append(EnterPlayers())
                    } else {
                        players.removeLast()
                    }
                }
        }
    }
}

private struct EnterPlayersView: View {
    @Binding var players: EnterPlayers
    
    var body: some View {
        VStack {
            SinglePlayerView(player: $players.team1Player)
            SinglePlayerView(player: $players.team2Player)
        }
    }
    
    struct SinglePlayerView: View {
        @State private var showingActionSheet = false
        @Binding var player: EnterPlayer
        @EnvironmentObject var playersViewModel: PlayersViewModel
        
        var body: some View {
            VStack(spacing: 0) {
                if let url = player.imageUrl {
                    RoundImageView(url: url)
                        .frame(width: PLAYER_ICON_SIZE, height: PLAYER_ICON_SIZE)
                } else {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .resizable()
                        .foregroundColor(.gray)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: PLAYER_ICON_SIZE, height: PLAYER_ICON_SIZE)
                }
                if let name = player.name {
                    Text(name)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .frame(width: PLAYER_ICON_SIZE + 8)
                }
            }
            .onTapGesture {
                showingActionSheet = true
            }
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(
                    title: Text("Select Player"),
                    buttons: playersViewModel.players.compactMap { selectablePlayer in
                        .default(Text(selectablePlayer.fullName)) {
                            self.player = EnterPlayer(player: selectablePlayer)
                        }
                    } + [
                        .destructive(Text("Remove")) { player = EnterPlayer() },
                        .cancel()
                    ]
                )
            }
        }
    }
}

struct EnterPlayers {
    var team1Player: EnterPlayer = EnterPlayer()
    var team2Player: EnterPlayer = EnterPlayer()
}

struct EnterPlayer {
    var id: String? = nil
    var name: String? = nil
    var imageUrl: String? = nil
    
    func toPlayer(players: [Player]) -> Player? {
        players.first { $0.id == id }
    }
}

private extension EnterPlayer {
    init(player: Player) {
        self.init(id: player.id, name: player.firstName, imageUrl: player.imageUrl)
    }
}

struct SelectPlayersView_Previews: PreviewProvider {
    static var previews: some View {
        TestWrapper()
    }
    
    struct TestWrapper: View {
        @State var players = [EnterPlayers()]
        
        var body: some View {
            SelectPlayersView(players: $players)
        }
    }
}
