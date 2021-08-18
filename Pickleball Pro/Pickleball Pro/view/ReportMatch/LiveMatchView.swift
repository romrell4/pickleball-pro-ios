//
//  LiveMatchView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/11/21.
//

import SwiftUI

struct LiveMatchView: View {
    @State private var match: Match = Match(id: "", date: Date(), team1: [Player.eric, Player.jessica], team2: [Player.bryan, Player.bob], scores: [GameScore()], stats: [])
    @State private var modalState: ModalState = .gone
    
    private var currentGameIndex: Int { match.scores.count - 1 }
    
    var body: some View {
        GeometryReader { fullScreen in
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.75))
                HStack(spacing: 4) {
                    ScoresView(
                        team1Score: $match.scores[currentGameIndex].team1Score,
                        team2Score: $match.scores[currentGameIndex].team2Score
                    ).padding(.leading, 8).padding(.bottom, 120)
                    
                    VStack(spacing: 0) {
                        PlayerSideView(modalState: $modalState, players: match.team1, isBottomView: false)
                        Image("pickleball_court")
                            .resizable()
                        PlayerSideView(modalState: $modalState, players: match.team2, isBottomView: true)
                    }.padding(.vertical)
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
                                match.stats.append(Stat(playerId: player.id, gameIndex: currentGameIndex, type: shot.type, result: shot.result, side: shot.side))
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
        .navigationBarTitle("Live Match", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu(content: {
                    Button("Finish Match") {
                        // TODO: Do something with the match? Save it?
                        print(match)
                    }
                    Button("Start New Game") {
                        match.scores.append(GameScore())
                    }
                }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 21))
                }
            }
        }
    }
}

private struct PlayerSideView: View {
    @Binding var modalState: ModalState
    var players: [Player]
    var isBottomView: Bool
    
    var body: some View {
        HStack {
            Spacer()
            RoundImageView(url: players[0].imageUrl)
                .frame(width: 50, height: 50)
                .onTapGesture {
                    modalState = .visible(player: players[0])
                }
            if players.count == 2 {
                Spacer()
                
                // The players need extra space on the bottom
                if isBottomView {
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

private struct ScoresView: View {
    @Binding var team1Score: Int
    @Binding var team2Score: Int
    
    private let pickleballImage: some View =
        Image("pickleball").resizable().frame(width: 20, height: 20)
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                pickleballImage
                pickleballImage
            }
            
            ScoreView(score: $team1Score)
                .padding(.bottom, 20)
            ScoreView(score: $team2Score)
        
            
            HStack(spacing: 0) {
                pickleballImage
                pickleballImage
            }
        }
    }
}

private struct ScoreView: View {
    @Binding var score: Int
    
    var body: some View {
        GroupBox {
            Text("\(score)").frame(width: 22)
        }.onTapGesture {
            score += 1
        }
    }
}

enum ModalState {
    case visible(player: Player)
    case gone
}

struct LiveMatchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LiveMatchView()
                .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}
