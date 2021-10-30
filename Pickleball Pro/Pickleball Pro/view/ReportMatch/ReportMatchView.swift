//
//  ReportMatchView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import SwiftUI

private let DISABLED_STEP_ALPHA = 0.2
private let SELECT_PLAYERS_ID = 0
private let ENTER_SCORES_ID = 1

struct ReportMatchView: View {
    @EnvironmentObject var playersViewModel: PlayersViewModel
    @EnvironmentObject var matchesViewModel: MatchesViewModel
    @Environment(\.currentTab) var currentTab
    
    @ObservedObject private var loginDelegate = LoginViewDelegate.instance
    
    @State private var alert: ProAlert? = nil
    @State private var showingLoginSheet = false
    @State private var selectedPlayers = [EnterPlayers()]
    @State private var enteredGameScores = [EnterGameScore()]
    
    @State private var playerValidationError = false
    @State private var scoreValidationError = false
    
    @State private var shouldNavigateToLiveMatch = false
    
    private var players: [Player] {
        if case let .success(players) = playersViewModel.state {
            return players
        } else {
            return []
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { scrollView in
                ZStack {
                    ScrollView {
                        VStack {
                            SelectPlayersStepView(selectedPlayers: $selectedPlayers, validationError: playerValidationError, allPlayers: players)
                                .id(SELECT_PLAYERS_ID)
                            EnterScoresStepView(
                                gameScores: $enteredGameScores,
                                validationError: scoreValidationError,
                                onTrackLiveMatchTapped: {
                                    guard loginDelegate.user != nil else {
                                        showingLoginSheet = true
                                        return
                                    }
                                    guard let _ = try? validatePlayers() else {
                                        scrollView.scrollTo(SELECT_PLAYERS_ID)
                                        return
                                    }
                                    shouldNavigateToLiveMatch = true
                                },
                                onSaveTapped: {
                                    guard loginDelegate.user != nil else {
                                        showingLoginSheet = true
                                        return
                                    }
                                    do {
                                        let match = try validateMatch()
                                        matchesViewModel.create(match: match) { error in
                                            if let error = error {
                                                alert = Alert(title: Text("Error"), message: Text(error.errorDescription)).toProAlert()
                                            } else {
                                                reset()
                                                currentTab.wrappedValue = .myMatches
                                            }
                                        }
                                    } catch MyError.playerValidationError {
                                        scrollView.scrollTo(SELECT_PLAYERS_ID)
                                    } catch MyError.scoreValidationError {
                                        scrollView.scrollTo(ENTER_SCORES_ID)
                                    } catch {}
                                }
                            ).id(ENTER_SCORES_ID)
                            NavigationLink(
                                destination: LiveMatchView(
                                    players: getPlayers()
                                ) {
                                    reset()
                                    currentTab.wrappedValue = .myMatches
                                },
                                isActive: $shouldNavigateToLiveMatch
                            ) { EmptyView() }
                        }
                    }
                    if playersViewModel.state.isLoading || matchesViewModel.state.isLoading {
                        LoadingModalView()
                    }
                }
            }
            .navigationBarTitle("Report Match")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .alert(item: $alert) { $0.alert }
            .sheet(isPresented: $showingLoginSheet) {
                LoginView()
            }
        }
        .onAppear {
            if loginDelegate.user != nil {
                playersViewModel.load()
            } else {
                showingLoginSheet = true
            }
        }
    }
    
    private func reset() {
        selectedPlayers = [EnterPlayers()]
        enteredGameScores = [EnterGameScore()]
        playerValidationError = false
        scoreValidationError = false
    }
    
    private func validateMatch() throws -> Match {
        let (team1, team2) = try validatePlayers()
        let scores = try validateScores()
        
        return Match(
            id: "",
            date: Date(),
            team1: team1,
            team2: team2,
            scores: scores,
            stats: []
        )
    }
    
    private func validatePlayers() throws -> ([Player], [Player]) {
        playerValidationError = false
        
        let (team1, team2) = getPlayers()
        
        guard team1.count == team2.count, team1.count > 0, team2.count > 0 else {
            playerValidationError = true
            throw MyError.playerValidationError
        }
        return (team1, team2)
    }
    
    private func getPlayers() -> ([Player], [Player]) {
        let (team1, team2) = selectedPlayers.map {
            ($0.team1Player.toPlayer(players: players), $0.team2Player.toPlayer(players: players))
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
        return (team1, team2)
    }
    
    private func validateScores() throws -> [GameScore] {
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
    let allPlayers: [Player]
    
    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading) {
                    Text("Step 1: Select Players")
                        .font(.title)
                        .foregroundColor(validationError ? .red : Color(.label))
                    SelectPlayersView(players: $selectedPlayers, allPlayers: allPlayers)
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
                    .foregroundColor(validationError ? .red : Color(.label))
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
            .environmentObject(PlayersViewModel(repository: TestRepository()))
            .environmentObject(MatchesViewModel(repository: TestRepository()))
    }
}
