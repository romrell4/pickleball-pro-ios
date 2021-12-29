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
    // TODO: Create ReportMatchViewModel?
    @EnvironmentObject var playersViewModel: PlayersViewModel
    @EnvironmentObject var matchesViewModel: MatchesViewModel
    private var loginManager: LoginManager {
        playersViewModel.loginManager
    }
    @Environment(\.currentTab) var currentTab
    
    @State private var alert: ProAlert? = nil
    @State private var showingLoginSheet = false
    @State private var selectedPlayers = [EnterPlayers()]
    @State private var enteredGameScores = [EnterGameScore()]
    
    @State private var playerValidationError = false
    
    @State private var navigateToLiveMatchWithPlayers: TeamPlayers? = nil
    @State private var showEnterScoreModalWithPlayers: TeamPlayers? = nil
    
    private var players: [Player] {
        if case let .success(players) = playersViewModel.state {
            return players
        } else {
            return []
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                SelectPlayersStepView(selectedPlayers: $selectedPlayers, validationError: playerValidationError, allPlayers: players)
                EnterScoresStepView(
                    onTrackLiveMatchTapped: {
                        if let players = canEnterScores() {
                            let match = LiveMatch(
                                team1: LiveMatchTeam(
                                    deucePlayer: LiveMatchPlayer(player: players.team1[0]),
                                    adPlayer: LiveMatchPlayer(player: players.team1[safe: 1])
                                ),
                                team2: LiveMatchTeam(
                                    deucePlayer: LiveMatchPlayer(player: players.team2[0]),
                                    adPlayer: LiveMatchPlayer(player: players.team2[safe: 1])
                                )
                            )
                            guard let data = try? JSONEncoder().encode(match) else { return }
                            NotificationCenter.default.post(name: .liveMatchStarted, object: nil, userInfo: ["match": data])
                        }
                    },
                    onEnterCompletedTapped: {
                        if let players = canEnterScores() {
                            showEnterScoreModalWithPlayers = players
                        }
                    }
                )
            }
            EnterScoresModal(item: $showEnterScoreModalWithPlayers, scores: $enteredGameScores) {
                playerValidationError = false
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
                    playerValidationError = true
                }
            }
            if playersViewModel.state.isLoading || matchesViewModel.state.isLoading {
                LoadingModalView()
            }
        }
        .alert(item: $alert) { $0.alert }
        .sheet(isPresented: $showingLoginSheet) {
            LoginView()
        }
        .onAppear {
            playersViewModel.load()
            showingLoginSheet = playersViewModel.state.isLoggedOut
        }
        .onReceive(NotificationCenter.default.publisher(for: .liveMatchSaved)) { _ in
            reset()
            currentTab.wrappedValue = .myMatches
        }
    }
    
    private func reset() {
        selectedPlayers = [EnterPlayers()]
        enteredGameScores = [EnterGameScore()]
        playerValidationError = false
    }
    
    private func canEnterScores() -> TeamPlayers? {
        guard loginManager.isLoggedIn else {
            showingLoginSheet = true
            return nil
        }
        playerValidationError = false
        guard let players = try? selectedPlayers.validate(players: players) else {
            playerValidationError = true
            return nil
        }
        return players
    }
    
    private func validateMatch() throws -> Match {
        let teamPlayers = try selectedPlayers.validate(players: players)
        let scores = try enteredGameScores.validate()
        
        return Match(
            id: "",
            date: Date(),
            team1: teamPlayers.team1,
            team2: teamPlayers.team2,
            scores: scores,
            stats: []
        )
    }
}

private extension Array {
    func validate(players: [Player]) throws -> TeamPlayers where Element == EnterPlayers {
        let (team1, team2) = self.map {
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
        guard team1.count == team2.count, team1.count > 0, team2.count > 0 else {
            throw MyError.playerValidationError
        }
        if (team1 + team2).count != Set((team1 + team2).map { $0.id }).count {
            throw MyError.playerValidationError
        }
        return TeamPlayers(team1: team1, team2: team2)
    }
    
    func validate() throws -> [GameScore] where Element == EnterGameScore {
        let scores: [GameScore] = try self.compactMap {
            // Filter out if they didn't put anything in the boxes
            guard !$0.team1.isEmpty && !$0.team2.isEmpty else { return nil }
            // Throw an error if they put something bad in the boxes
            guard let team1Score = Int($0.team1), let team2Score = Int($0.team2) else {
                throw MyError.scoreValidationError
            }
            return GameScore(team1Score: team1Score, team2Score: team2Score)
        }
        return scores
    }
}

private enum MyError: Error {
    case playerValidationError
    case scoreValidationError
}

private struct TeamPlayers: Identifiable {
    let team1: [Player]
    let team2: [Player]
    
    var id: String {
        (team1 + team2).map { $0.id }.joined(separator: "")
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
    var onTrackLiveMatchTapped: () -> Void
    var onEnterCompletedTapped: () -> Void
    
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
                    .onTapGesture {
                        onTrackLiveMatchTapped()
                    }
                Text("or")
                Text("Enter Completed Match Scores")
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(Capsule().fill(Color.blue))
                    .onTapGesture {
                        onEnterCompletedTapped()
                    }
            }
        }.padding()
    }
}

private struct EnterScoresModal: View {
    @Binding var item: TeamPlayers?
    @Binding var scores: [EnterGameScore]
    let onSaveTapped: () throws -> Void
    
    @State private var validationError: Bool = false
    
    var body: some View {
        if let teamPlayers = item {
            ModalView(onDismiss: { item = nil }) {
                VStack {
                    Text("Enter match scores")
                        .font(.title2)
                        .foregroundColor(validationError ? .red : Color(.label))
                    EnterMatchScoreView(team1: teamPlayers.team1, team2: teamPlayers.team2, scores: $scores)
                    Button("Save") {
                        do {
                            try onSaveTapped()
                        } catch (e: MyError.scoreValidationError) {
                            validationError = true
                        } catch {}
                    }
                }
            }
        } else {
            VStack {}
        }
    }
}

#if DEBUG
struct ReportMatchView_Previews: PreviewProvider {
    static var previews: some View {
        ReportMatchView()
            .environmentObject(PlayersViewModel(repository: TestRepository(), loginManager: TestLoginManager()))
            .environmentObject(MatchesViewModel(repository: TestRepository(), loginManager: TestLoginManager()))
    }
}
#endif
