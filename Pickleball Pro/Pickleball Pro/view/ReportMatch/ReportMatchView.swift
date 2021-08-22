//
//  ReportMatchView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import SwiftUI

private let DISABLED_STEP_ALPHA = 0.2

struct ReportMatchView: View {
    @EnvironmentObject var playersViewModel: PlayersViewModel
    
    @State private var showingAlert = false
    @State private var selectedPlayers = [EnterPlayers()]
    @State private var enteredGameScores = [EnterGameScore()]
    
    @State private var playerValidationError = false
    @State private var scoreValidationError = false
    
    @State private var shouldNavigateToLiveMatch = false
    
    var body: some View {
        NavigationView {
            VStack {
                SelectPlayersStepView(selectedPlayers: $selectedPlayers, validationError: playerValidationError)
                EnterScoresStepView(
                    gameScores: $enteredGameScores,
                    validationError: scoreValidationError,
                    onTrackLiveMatchTapped: {
                        if let (team1, team2) = try? getPlayers() {
                            print(team1)
                            print(team2)
                            reset()
                            shouldNavigateToLiveMatch = true
                        }
                    },
                    onSaveTapped: {
                        if let match = try? getMatch() {
                            print(match)
                            // TODO: Save it
                            reset()
                        }
                    }
                )
                NavigationLink(destination: LiveMatchView(players: getPlayersWithoutThrow()), isActive: $shouldNavigateToLiveMatch) { EmptyView() }
            }
            .navigationBarTitle("Report Match")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Match Saved!"))
            }
        }
    }
    
    private func reset() {
        selectedPlayers = [EnterPlayers()]
        enteredGameScores = [EnterGameScore()]
        playerValidationError = false
        scoreValidationError = false
    }
    
    private func getMatch() throws -> Match? {
        let (team1, team2) = try getPlayers()
        let scores = try getScores()
        
        return Match(
            id: "",
            date: Date(),
            team1: team1,
            team2: team2,
            scores: scores,
            stats: []
        )
    }
    
    private func getPlayersWithoutThrow() -> ([Player], [Player]) {
        return ([Player.eric, Player.jessica], [Player.bryan, Player.bob])
        
        if let players = try? getPlayers() {
            return players
        } else {
            return ([Player.eric], [Player.eric])
        }
    }
    
    private func getPlayers() throws -> ([Player], [Player]) {
        playerValidationError = false
        
        let (team1, team2) = selectedPlayers.map {
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
            throw MyError.playerValidationError
        }
        return (team1, team2)
    }
    
    private func getScores() throws -> [GameScore] {
        scoreValidationError = false
        
        let scores: [GameScore] = try enteredGameScores.map {
            guard let team1Score = Int($0.team1), let team2Score = Int($0.team2) else {
                scoreValidationError = true
                throw MyError.scoreValidationError
            }
            return GameScore(team1Score: team1Score, team2Score: team2Score)
        }
        return scores
    }
    
    enum MyError: Error {
        case playerValidationError
        case scoreValidationError
    }
}

private struct SelectPlayersStepView: View {
    @EnvironmentObject var playersViewModel: PlayersViewModel
    @Binding var selectedPlayers: [EnterPlayers]
    var validationError: Bool
    
    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading) {
                    Text("Step 1: Select Players")
                        .font(.title)
                        .foregroundColor(validationError ? .red : .black)
                    SelectPlayersView(players: $selectedPlayers)
                }
                Spacer()
            }
        }.padding()
    }
}

private struct EnterScoresStepView: View {
    @Binding var gameScores: [EnterGameScore]
    var validationError: Bool
    var onTrackLiveMatchTapped: () -> Void
    var onSaveTapped: () -> Void
    
    var body: some View {
        GroupBox {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Step 2: Enter Scores")
                            .font(.title)
                    }
                    Spacer()
                }
                Text("Track Live Match")
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(Capsule().fill(Color.green))
                    .padding()
                    .onTapGesture {
                        onTrackLiveMatchTapped()
                    }
                Text("or")
                Text("Enter Completed Match Scores:")
                    .font(.title2)
                    .padding(.vertical)
                    .foregroundColor(validationError ? .red : .black)
                EnterMatchScoreView(scores: $gameScores)
                Button("Save") {
                    onSaveTapped()
                }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(Capsule().fill(Color.blue))
            }
        }.padding()
    }
}

struct ReportMatchView_Previews: PreviewProvider {
    static var previews: some View {
        ReportMatchView()
            .environmentObject(PlayersViewModel())
    }
}
