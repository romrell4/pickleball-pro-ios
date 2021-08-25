//
//  LiveMatchView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/11/21.
//

import SwiftUI

struct LiveMatchView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var match: LiveMatch
    @State private var modalState: ModalState = .gone
    
    init?(players: ([Player], [Player])) {
        guard players.0.count > 0 && players.1.count > 0 else {
            return nil
        }
        _match = State(initialValue: LiveMatch(
            team1: LiveMatchTeam(
                player1: LiveMatchPlayer(player: players.0[0], servingState: .serving(isFirstServer: players.0.count == 1)),
                player2: LiveMatchPlayer(player: players.0[safe: 1])
            ),
            team2: LiveMatchTeam(
                player1: LiveMatchPlayer(player: players.1[0]),
                player2: LiveMatchPlayer(player: players.1[safe: 1])
            )
        ))
    }
    
    var body: some View {
        GeometryReader { fullScreen in
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.75))
                HStack(spacing: 4) {
                    VStack {
                        // TODO: Display previous games?
                        ScoreView(score: $match.team1.scores[match.currentGameIndex])
                            .padding(.bottom, 20)
                        ScoreView(score: $match.team2.scores[match.currentGameIndex])
                    }.padding(.leading, 8).padding(.bottom, 120)
                    
                    VStack(spacing: 0) {
                        TeamView(modalState: $modalState, team: match.team1, isBottomView: false)
                        Image("pickleball_court")
                            .resizable()
                        TeamView(modalState: $modalState, team: match.team2, isBottomView: true)
                    }.padding(.vertical)
                }
                switch modalState {
                case .visible(let player, let savedShot):
                    ZStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.25))
                            .onTapGesture {
                                modalState = .gone
                            }
                        StatTracker(shot: savedShot) { savedShot in
                            if let shot = savedShot {
                                match.pointFinished(with: shot, by: player)
                            }
                            modalState = .gone
                        }
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
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
                        // TODO: Save the match?
                        print(match)
                        presentationMode.wrappedValue.dismiss()
                    }
                    Button("Start New Game") {
                        match.startNewGame()
                    }
                    Button("Edit Last Shot") {
                        if let stat = match.stats.popLast() {
                            modalState = .visible(player: match.player(for: stat.playerId), savedShot: stat.shot)
                        }
                    }
                }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 21))
                }
            }
        }
    }
}

private struct TeamView: View {
    @Binding var modalState: ModalState
    var team: LiveMatchTeam
    var isBottomView: Bool
    
    var body: some View {
        HStack {
            Spacer()
            if isBottomView {
                if let player2 = team.player2 {
                    PlayerView(modalState: $modalState, player: player2)
                    Spacer()
                    Spacer()
                }
                PlayerView(modalState: $modalState, player: team.player1)
            } else {
                PlayerView(modalState: $modalState, player: team.player1)
                if let player2 = team.player2 {
                    Spacer()
                    PlayerView(modalState: $modalState, player: player2)
                }
            }
            Spacer()
        }
    }
}

private struct PlayerView: View {
    @Binding var modalState: ModalState
    var player: LiveMatchPlayer
    
    private let pickleballImage: some View =
        Image("pickleball").resizable().frame(width: 20, height: 20)
    
    var body: some View {
        HStack(spacing: 4) {
            RoundImageView(url: player.imageUrl)
                .frame(width: 50, height: 50)
                .onTapGesture {
                    modalState = .visible(player: player)
                }
            VStack(spacing: 4) {
                switch player.servingState {
                case .serving(let isFirstServer):
                    pickleballImage
                    if !isFirstServer {
                        pickleballImage
                    }
                case .notServing: EmptyView()
                }
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

private enum ModalState {
    case visible(player: LiveMatchPlayer, savedShot: Stat.Shot? = nil)
    case gone
}

struct LiveMatch {
    var team1: LiveMatchTeam
    var team2: LiveMatchTeam
    var stats: [Stat] = []
    
    var allPlayers: [LiveMatchPlayer] { team1.players + team2.players }
    
    var isDoubles: Bool { team1.player2 != nil && team2.player2 != nil }
    
    var currentGameIndex: Int { team1.scores.count - 1 }
    
    var currentServer: LiveMatchPlayer { allPlayers.first { $0.isServing }! }
    
    var currentServingTeam: LiveMatchTeam {
        team1.players.contains(currentServer) ? team1 : team2
    }
    
    func player(for id: String) -> LiveMatchPlayer {
        allPlayers.first { $0.id == id }!
    }
    
    mutating func startNewGame() {
        team1.scores.append(0)
        team2.scores.append(0)
    }
    
    mutating func pointFinished(with shot: Stat.Shot, by player: LiveMatchPlayer) {
        stats.append(Stat(playerId: player.id, gameIndex: currentGameIndex, shotType: shot.type, shotResult: shot.result, shotSide: shot.side))
        
        let playerTeam = team1.players.contains(player) ? team1 : team2
        
        // If it was a winner by the serving team or an error by the receiving team, add a point to the serving team
        // If it was an error by the serving team or a winner by the receiving team, rotate servers
        if (shot.result == .winner && playerTeam.isServing) ||
            (shot.result == .error && !playerTeam.isServing) {
            if team1.isServing {
                team1.earnPoint()
            } else {
                team2.earnPoint()
            }
        } else {
            rotateServer()
        }
    }
    
    mutating func rotateServer() {
        if isDoubles {
            switch team1.player1.servingState {
            case .serving(let isFirstServer):
                if isFirstServer {
                    team1.player2?.servingState = .serving(isFirstServer: false)
                } else {
                    team2.player1.servingState = .serving(isFirstServer: true)
                }
                team1.player1.servingState = .notServing
                return
            default: break
            }
            
            switch team1.player2?.servingState {
            case .serving(let isFirstServer):
                if isFirstServer {
                    team1.player1.servingState = .serving(isFirstServer: false)
                } else {
                    team2.player1.servingState = .serving(isFirstServer: true)
                }
                team1.player2?.servingState = .notServing
                return
            default: break
            }
            
            switch team2.player1.servingState {
            case .serving(let isFirstServer):
                if isFirstServer {
                    team2.player2?.servingState = .serving(isFirstServer: false)
                } else {
                    team1.player1.servingState = .serving(isFirstServer: true)
                }
                team2.player1.servingState = .notServing
                return
            default: break
            }
            
            switch team2.player2?.servingState {
            case .serving(let isFirstServer):
                if isFirstServer {
                    team2.player1.servingState = .serving(isFirstServer: false)
                } else {
                    team1.player1.servingState = .serving(isFirstServer: true)
                }
                team2.player2?.servingState = .notServing
                return
            default: break
            }
        } else {
            if team1.player1.isServing {
                team2.player1.servingState = .serving()
                team1.player1.servingState = .notServing
            } else {
                team1.player1.servingState = .serving()
                team2.player1.servingState = .notServing
            }
        }
    }
    
    func toMatch() -> Match {
        Match(
            id: "",
            date: Date(),
            team1: team1.players.map { $0.player },
            team2: team2.players.map { $0.player },
            scores: zip(team1.scores, team2.scores)
                .map { GameScore(team1Score: $0.0, team2Score: $0.1) },
            stats: stats
        )
    }
}

struct LiveMatchTeam {
    var player1: LiveMatchPlayer
    var player2: LiveMatchPlayer?
    var scores: [Int] = [0]
    
    var players: [LiveMatchPlayer] { [player1, player2].compactMap { $0 } }
    var isServing: Bool { players.contains { $0.isServing } }
    
    mutating func earnPoint() {
        scores[scores.count - 1] += 1
        
        // If it's doubles, switch sides
        if let player2 = player2 {
            let tempPlayer = player1
            self.player1 = player2
            self.player2 = tempPlayer
        }
    }
}

struct LiveMatchPlayer: Equatable {
    var player: Player
    
    var id: String { player.id }
    var imageUrl: String { player.imageUrl }
    
    var servingState: ServingState = .notServing
    
    var isServing: Bool {
        switch servingState {
        case .notServing: return false
        case .serving(_): return true
        }
    }
    
    static func == (lhs: LiveMatchPlayer, rhs: LiveMatchPlayer) -> Bool {
        lhs.id == rhs.id
    }
    
    enum ServingState {
        case notServing
        case serving(isFirstServer: Bool = true)
    }
}

extension LiveMatchPlayer {
    init?(player: Player?, servingState: ServingState = .notServing) {
        if let player = player {
            self.init(player: player, servingState: servingState)
        } else {
            return nil
        }
    }
}

struct LiveMatchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LiveMatchView(players: ([Player.eric, Player.jessica], [Player.bryan, Player.bob]))
                .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}
