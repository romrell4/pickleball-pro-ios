//
//  LiveMatchView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/11/21.
//

import SwiftUI

extension Notification.Name {
    static let liveMatchStarted = Notification.Name("liveMatchStarted")
    static let liveMatchSaved = Notification.Name("liveMatchSaved")
}

struct LiveMatchView: View {
    @ObservedObject private var viewModel: LiveMatchViewModel
    @EnvironmentObject var matchesViewModel: MatchesViewModel
    @Environment(\.presentationMode) var presentationMode
    @AppStorage(PreferenceKeys.autoSwitchSides) var autoSwitchSides = false
    @AppStorage(PreferenceKeys.liveMatchConfirmations) var requireConfirmations = true
    @State private var statTrackerModalState: StatTrackerModalState = .gone
    @State private var manualScoreEditModalVisible: Bool = false
    @State private var alert: ProAlert? = nil
    @State private var matchStatsModalVisible: Bool = false
    
    @State private var isReachable = false
    
    init?(team1: [Player], team2: [Player]) {
        guard team1.count > 0 && team2.count > 0 else { return nil }
        viewModel = LiveMatchViewModel(initialMatch: LiveMatch(
            team1: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(
                    player: team1[0]
                    //,servingState: .serving(isFirstServer: players.0.count == 1)
                ),
                adPlayer: LiveMatchPlayer(player: team1[safe: 1])
            ),
            team2: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: team2[0]),
                adPlayer: LiveMatchPlayer(player: team2[safe: 1])
            )
        ))
    }
    
    init(match: LiveMatch) {
        viewModel = LiveMatchViewModel(initialMatch: match)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .fill(Color("liveMatchBackground"))
                    .edgesIgnoringSafeArea(.bottom)
                VStack(spacing: 0) {
                    TeamView(statTrackerModalState: $statTrackerModalState, team: viewModel.match.team1, isBottomView: false)
                    Image("pickleball_court")
                        .resizable()
                    TeamView(statTrackerModalState: $statTrackerModalState, team: viewModel.match.team2, isBottomView: true)
                }
                .padding(.vertical)
                .padding(.leading, 80)
                
                ScoresView(match: $viewModel.match)
                
                switch statTrackerModalState {
                case .visible(let player, let previousShot):
                    ModalView(onDismiss: { statTrackerModalState = .gone }) {
                        StatTracker(player: player.player, shot: previousShot) { newShot in
                            if let shot = newShot {
                                viewModel.match.pointFinished(with: shot)
                            }
                            statTrackerModalState = .gone
                        }
                    }
                case .gone: EmptyView()
                }
                if viewModel.match.currentServer == nil {
                    ModalView(onDismiss: {}) {
                        SelectServerView(match: $viewModel.match) { player in
                            viewModel.serverSelected(playerId: player.id)
                        }
                    }
                }
                if manualScoreEditModalVisible {
                    ModalView(onDismiss: { manualScoreEditModalVisible = false }) {
                        ManualScoreEditView(match: $viewModel.match) {
                            manualScoreEditModalVisible = false
                        }
                    }
                }
                
                if matchesViewModel.state.isLoading {
                    LoadingModalView()
                }
            }
            .navigationBarTitle("Live Match", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $matchStatsModalVisible) {
                MatchDetailView(match: viewModel.match.toMatch())
            }
            .alert(item: $alert, content: { $0.alert })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        alert = Alert(
                            title: Text("Are you sure?"),
                            message: Text("By leaving this screen, you will lose any data that you have tracked as part of this match."),
                            primaryButton: .destructive(Text("Yes")) {
                                viewModel.closeMatch()
                                self.presentationMode.wrappedValue.dismiss()
                            },
                            secondaryButton: .cancel(Text("No"))
                        ).toProAlert()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu(content: {
                        Button("Finish Match") {
                            if requireConfirmations {
                                alert = Alert(
                                    title: Text("Are you sure?"),
                                    message: Text("You will not be able to come back to edit this match after finishing it."),
                                    primaryButton: .default(Text("Yes")) {
                                        finishMatch()
                                    },
                                    secondaryButton: .cancel(Text("No"))
                                ).toProAlert()
                            } else {
                                finishMatch()
                            }
                        }
                        Button("Start New Game") {
                            if requireConfirmations {
                                alert = Alert(
                                    title: Text("Are you sure?"),
                                    message: Text("You will not be able to come back to edit this game after starting a new one."),
                                    primaryButton: .default(Text("Yes")) {
                                        viewModel.startNewGame(autoSwitchSides: autoSwitchSides)
                                    },
                                    secondaryButton: .cancel(Text("No"))
                                ).toProAlert()
                            } else {
                                viewModel.startNewGame(autoSwitchSides: autoSwitchSides)
                            }
                        }
                        Button("Edit Score") {
                            manualScoreEditModalVisible = true
                        }
                        Button("Switch Court Sides") {
                            viewModel.match.switchCourtSides()
                        }
                        if viewModel.match.canUndoLastShot() {
                            Button("Undo Last Shot") {
                                if let result = viewModel.match.pointResults.popLast() {
                                    switch result.scoreResult {
                                    case .team1Point:
                                        viewModel.match.team1.losePoint()
                                        viewModel.match.switchSides(isTeam1Intiating: true)
                                    case .team2Point:
                                        viewModel.match.team2.losePoint()
                                        viewModel.match.switchSides(isTeam1Intiating: false)
                                    case .sideout(let previousServerId, let wasFirstServer):
                                        viewModel.match.unrotateServer(previousServerId: previousServerId, wasFirstServer: wasFirstServer)
                                    }
                                    statTrackerModalState = .visible(
                                        player: viewModel.match.player(for: result.shot.playerId),
                                        savedShot: result.shot
                                    )
                                }
                            }
                        }
                        Button("View Match Stats") {
                            matchStatsModalVisible = true
                        }
                    }) {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.checkForReceivedMatch()
        }
    }
    
    private func finishMatch() {
        // TODO: Allow for sharing
        matchesViewModel.create(match: viewModel.match.toMatch()) { error in
            if let error = error {
                alert = Alert(title: Text("Error"), message: Text(error.errorDescription)).toProAlert()
            } else {
                viewModel.closeMatch()
                presentationMode.wrappedValue.dismiss()
                NotificationCenter.default.post(name: .liveMatchSaved, object: nil)
            }
        }
    }
}

private struct TeamView: View {
    @Binding var statTrackerModalState: StatTrackerModalState
    var team: LiveMatchTeam
    var isBottomView: Bool
    
    var body: some View {
        HStack {
            Spacer()
            if isBottomView {
                PlayerView(statTrackerModalState: $statTrackerModalState, player: team.adPlayer)
                Spacer()
                Spacer()
                PlayerView(statTrackerModalState: $statTrackerModalState, player: team.deucePlayer)
            } else {
                PlayerView(statTrackerModalState: $statTrackerModalState, player: team.deucePlayer)
                Spacer()
                PlayerView(statTrackerModalState: $statTrackerModalState, player: team.adPlayer)
            }
            Spacer()
        }
    }
}

private struct PlayerView: View {
    @Binding var statTrackerModalState: StatTrackerModalState
    var player: LiveMatchPlayer?
    
    var body: some View {
        if let player = player {
            player.imageWithServer(imageSize: 50).onTapGesture {
                statTrackerModalState = .visible(player: player)
            }
        } else {
            Spacer().frame(width: 50)
        }
    }
}

private struct ScoresView: View {
    @State private var showingPreviousGames: Bool = false
    @Binding var match: LiveMatch
    
    var body: some View {
        HStack(spacing: 4) {
            HStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    if match.currentGameIndex > 0 {
                        Image(systemName: "chevron.backward.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                            .rotationEffect(showingPreviousGames ? .degrees(180) : .zero)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.7)) {
                                    showingPreviousGames.toggle()
                                }
                            }
                        Spacer()
                    }
                    HStack {
                        ForEach(match.team1.scores.indices, id: \.self) { index in
                            if showingPreviousGames || index == match.currentGameIndex {
                                VStack {
                                    ScoreView(score: match.team1.scores[index])
                                        .padding(.bottom, 15)
                                    ScoreView(score: match.team2.scores[index])
                                }
                            }
                        }
                    }.padding(.leading, 16)
                }.padding(.leading, 4)
                Spacer()
            }.padding(.bottom, 120)
        }
    }
}

private struct ScoreView: View {
    let score: Int
    
    var body: some View {
        GroupBox {
            Text("\(score)").frame(width: 22)
        }
    }
}

private enum StatTrackerModalState {
    case visible(player: LiveMatchPlayer, savedShot: LiveMatchShot? = nil)
    case gone
}

#if DEBUG
struct LiveMatchView_Previews: PreviewProvider {
    static var previews: some View {
        LiveMatchView(
            team1: [Player.eric],//, Player.jessica],
            team2: [Player.bryan]//, Player.bob]
        )
        .environmentObject(MatchesViewModel(repository: TestRepository(), loginManager: TestLoginManager()))
    }
}
#endif
