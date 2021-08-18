//
//  EnterMatchScoreView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/11/21.
//

import SwiftUI

struct EnterMatchScoreView: View {
    @State private var players = [EnterPlayers()]
    @State private var scores = [EnterGameScore()]
    
    @State private var playerValidationError = false
    @State private var scoreValidationError = false
    
    @EnvironmentObject var playersViewModel: PlayersViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Select Players...")
                    .font(.caption)
                    .foregroundColor(playerValidationError ? .red : .black)
                Spacer()
                Text("Enter Scores...")
                    .font(.caption)
                    .foregroundColor(scoreValidationError ? .red : .black)
            }
            HStack {
                ForEach(players.indices, id: \.self) { index in
                    EnterPlayersView(players: .proxy($players[index]))
                }
                let canAdd = players.count < 2
                Image(systemName: canAdd ? "plus.circle.fill" : "minus.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        if canAdd {
                            players.append(EnterPlayers())
                        } else {
                            players.removeLast()
                        }
                    }
                
                Spacer()
                // TODO: Handle scrolling?
                ForEach(scores.indices, id: \.self) { index in
                    GameScoreView(score: .proxy($scores[index]))
                }
                VStack {
                    if scores.count < 5 {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                            .onTapGesture {
                                scores.append(EnterGameScore())
                            }
                    }
                    if scores.count > 1 {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                            .onTapGesture {
                                scores.removeLast()
                            }
                    }
                }
            }.padding(.bottom, 8)
            Button("Save") {
                if let match = getMatch() {
                    print(match)
                }
            }
        }
        .padding(.horizontal, 8)
        .onAppear {
            playersViewModel.load()
        }
    }
    
    private func getMatch() -> Match? {
        // Reset validation errors
        playerValidationError = false
        scoreValidationError = false
        
        let (team1, team2) = players.map {
            ($0.team1Player.toPlayer(players: playersViewModel.players), $0.team2Player.toPlayer(players: playersViewModel.players))
        }.reduce(([Player](), [Player]())) { soFar, next in
            var soFar = soFar
            if let team1Player = next.0 {
                soFar.0.append(team1Player)
            }
            if let team2Player = next.1 {
                soFar.1.append(team2Player)
            }
            return soFar
        }
        
        guard team1.count == team2.count, team1.count > 0, team2.count > 0 else {
            playerValidationError = true
            return nil
        }
        
        
        var scores = [GameScore]()
        do {
            scores = try validateScores()
        } catch {
            scoreValidationError = true
            return nil
        }
        
        return Match(
            // TODO: How to handle ID creation?
            id: "",
            date: Date(),
            team1: team1,
            team2: team2,
            scores: scores,
            stats: []
        )
    }
    
    private func validateScores() throws -> [GameScore] {
        try scores.map {
            guard let team1Score = Int($0.team1), let team2Score = Int($0.team2) else {
                throw MyError.scoreValidationError
            }
            return GameScore(team1Score: team1Score, team2Score: team2Score)
        }
    }
    
    enum MyError: Error {
        case scoreValidationError
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

extension EnterPlayer {
    init(player: Player) {
        self.init(id: player.id, name: player.name, imageUrl: player.imageUrl)
    }
}

struct EnterPlayersView: View {
    @Binding var players: EnterPlayers
    
    var body: some View {
        VStack {
            SinglePlayerView(player: $players.team1Player)
            SinglePlayerView(player: $players.team2Player)
        }
    }
    
    struct SinglePlayerView: View {
        private let size: CGFloat = 30
        
        @State private var showingActionSheet = false
        @Binding var player: EnterPlayer
        @EnvironmentObject var playersViewModel: PlayersViewModel
        
        var body: some View {
            VStack(spacing: 0) {
                if let url = player.imageUrl {
                    RoundImageView(url: url)
                        .frame(width: size, height: size)
                } else {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .resizable()
                        .foregroundColor(.gray) // TODO: Figure out colors
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                }
                if let name = player.name {
                    Text(name)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .frame(width: size + 8)
                }
            }
            .onTapGesture {
                showingActionSheet = true
            }
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(
                    title: Text("Select Player"),
                    buttons: playersViewModel.players.compactMap { selectablePlayer in
                        .default(Text(selectablePlayer.name)) {
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

struct EnterGameScore {
    let id = UUID()
    var team1: String = ""
    var team2: String = ""
}

struct GameScoreView: View {
    @Binding var score: EnterGameScore
    
    var body: some View {
        VStack {
            SingleScoreView(textBinding: $score.team1)
            SingleScoreView(textBinding: $score.team2)
        }
    }
    
    struct SingleScoreView: View {
        @Binding var textBinding: String
        
        var body: some View {
            TextField("", text: $textBinding)
                .multilineTextAlignment(.center)
                .frame(width: 20, height: 20)
                .padding(8)
                .font(.caption)
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray))
        }
    }
}

extension Binding {
    static func proxy(_ source: Binding<Value>) -> Binding<Value> {
        self.init(
            get: { source.wrappedValue },
            set: { source.wrappedValue = $0 }
        )
    }
}

struct EnterMatchScoreView_Previews: PreviewProvider {
    static var previews: some View {
        EnterMatchScoreView()
            .environmentObject(PlayersViewModel())
    }
}
