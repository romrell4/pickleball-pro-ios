//
//  LiveMatchView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/11/21.
//

import SwiftUI

struct LiveMatchView: View {
    @State var modalState: ModalState = .gone
    @State var currentGameIndex = 0
    @State private var stats = [Stat]()
    
    var body: some View {
        GeometryReader { fullScreen in
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.75))
                HStack(spacing: 4) {
                    // TODO: Make score real
                    VStack(spacing: 20) {
                        GroupBox {
                            Text("7")
                        }
                        GroupBox {
                            Text("4")
                        }
                    }
                    .padding(.leading, 8)
                    .padding(.bottom, 120)
                    VStack(spacing: 0) {
                        PlayerSideView(modalState: $modalState, players: [Player.eric, Player.jessica], middleSpacers: 1)
                        Image("pickleball_court")
                            .resizable()
                        PlayerSideView(modalState: $modalState, players: [Player.bryan, Player.bob], middleSpacers: 2)
                    }
                    .padding(.vertical)
                }
                switch modalState {
                case .visible(let player):
                    ZStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.25))
                            .onTapGesture {
                                modalState = .gone
                            }
                        StatTracker { savedShot in
                            if let shot = savedShot {
                                self.stats.append(Stat(playerId: player.id, gameIndex: currentGameIndex, type: shot.type, result: shot.result, side: shot.side))
                            }
                            modalState = .gone
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20).fill(Color.white)
                        )
                    }
                case .gone: EmptyView()
                }
            }
        }
    }
}

private struct PlayerSideView: View {
    @Binding var modalState: ModalState
    var players: [Player]
    var middleSpacers: Int
    
    var body: some View {
        HStack {
            Spacer()
            RoundImageView(url: players[0].imageUrl)
                .frame(width: 50, height: 50)
                .onTapGesture {
                    modalState = .visible(player: players[0])
                }
            if players.count == 2 {
                ForEach(0..<middleSpacers) { _ in
                    Spacer()
                }
                RoundImageView(url: players[1].imageUrl)
                    .frame(width: 50, height: 50)
                    .onTapGesture {
                        modalState = .visible(player: players[0])
                    }
            }
            Spacer()
        }
    }
}

enum ModalState {
    case visible(player: Player)
    case gone
}

struct LiveMatchView_Previews: PreviewProvider {
    static var previews: some View {
        LiveMatchView()
    }
}
