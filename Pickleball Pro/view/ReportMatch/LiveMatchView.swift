//
//  LiveMatchView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/11/21.
//

import SwiftUI

struct LiveMatchView: View {
    // TODO: Add a menu option to "Edit Scores" which will bring up a dialog to modify the current score and player configuration
    @EnvironmentObject var matchesViewModel: MatchesViewModel
    @Environment(\.presentationMode) var presentationMode
    @AppStorage(PreferenceKeys.autoSwitchSides) var autoSwitchSides = false
    @AppStorage(PreferenceKeys.liveMatchConfirmations) var requireConfirmations = true
    @State private var match: LiveMatch
    @State private var statTrackerModalState: StatTrackerModalState = .gone
    @State private var selectServerModalVisible: Bool = true
    @State private var manualScoreEditModalVisible: Bool = false
    @State private var alert: ProAlert? = nil
    @State private var matchStatsModalVisible: Bool = false
    
    var onMatchSaved: () -> Void
    
    init?(team1: [Player], team2: [Player], onMatchSaved: @escaping () -> Void) {
        guard team1.count > 0 && team2.count > 0 else { return nil }
        _match = State(initialValue: LiveMatch(
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
        self.onMatchSaved = onMatchSaved
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .fill(Color("liveMatchBackground"))
                    .edgesIgnoringSafeArea(.bottom)
                VStack(spacing: 0) {
                    TeamView(statTrackerModalState: $statTrackerModalState, team: match.team1, isBottomView: false)
                    Image("pickleball_court")
                        .resizable()
                    TeamView(statTrackerModalState: $statTrackerModalState, team: match.team2, isBottomView: true)
                }
                .padding(.vertical)
                .padding(.leading, 80)
                
                ScoresView(match: $match)
                
                switch statTrackerModalState {
                case .visible(let player, let previousShot):
                    ModalView(onDismiss: { statTrackerModalState = .gone }) {
                        StatTracker(player: player.player, shot: previousShot) { newShot in
                            if let shot = newShot {
                                match.pointFinished(with: shot)
                            }
                            statTrackerModalState = .gone
                        }
                    }
                case .gone: EmptyView()
                }
                if selectServerModalVisible {
                    ModalView(onDismiss: {}) {
                        SelectServerView(match: $match) { player in
                            selectServerModalVisible = false
                            
                            match.setServer(playerId: player.id, isFirstServer: !match.isDoubles)
                            
                            // If they selected a player on the ad side, switch sides
                            switch player.id {
                            case match.team1.adPlayer?.id:
                                match.switchSides(isTeam1Intiating: true)
                            case match.team2.adPlayer?.id:
                                match.switchSides(isTeam1Intiating: false)
                            default: break
                            }
                        }
                    }
                }
                if manualScoreEditModalVisible {
                    ModalView(onDismiss: { manualScoreEditModalVisible = false }) {
                        ManualScoreEditView(match: $match) {
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
                MatchDetailView(match: match.toMatch())
            }
            .alert(item: $alert, content: { $0.alert })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        alert = Alert(
                            title: Text("Are you sure?"),
                            message: Text("By leaving this screen, you will lose any data that you have tracked as part of this match."),
                            primaryButton: .destructive(Text("Yes")) { self.presentationMode.wrappedValue.dismiss()
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
                                        startNewGame()
                                    },
                                    secondaryButton: .cancel(Text("No"))
                                ).toProAlert()
                            } else {
                                startNewGame()
                            }
                        }
                        Button("Edit Score") {
                            manualScoreEditModalVisible = true
                        }
                        Button("Switch Court Sides") {
                            match.switchCourtSides()
                        }
                        if match.canUndoLastShot() {
                            Button("Undo Last Shot") {
                                if let result = match.pointResults.popLast() {
                                    switch result.scoreResult {
                                    case .team1Point:
                                        match.team1.losePoint()
                                        match.switchSides(isTeam1Intiating: true)
                                    case .team2Point:
                                        match.team2.losePoint()
                                        match.switchSides(isTeam1Intiating: false)
                                    case .sideout(let previousServerId, let wasFirstServer):
                                        match.unrotateServer(previousServerId: previousServerId, wasFirstServer: wasFirstServer)
                                    }
                                    statTrackerModalState = .visible(
                                        player: match.player(for: result.shot.playerId),
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
    }
    
    private func startNewGame() {
        match.startNewGame()
        
        if autoSwitchSides {
            match.switchCourtSides()
        }
        
        selectServerModalVisible = true
    }
    
    private func finishMatch() {
        // TODO: Allow for sharing
        matchesViewModel.create(match: match.toMatch()) { error in
            if let error = error {
                alert = Alert(title: Text("Error"), message: Text(error.errorDescription)).toProAlert()
            } else {
                presentationMode.wrappedValue.dismiss()
                onMatchSaved()
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
            HStack(spacing: 4) {
                player.player.image()
                    .frame(width: 50, height: 50)
                    .onTapGesture {
                        statTrackerModalState = .visible(player: player)
                    }
                player.servingState.image
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

extension LiveMatchPlayer.ServingState {
    var image: some View {
        VStack(spacing: 4) {
            let pickleballImage = Image("pickleball")
                .resizable()
                .frame(width: 20, height: 20)
            switch self {
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

private enum StatTrackerModalState {
    case visible(player: LiveMatchPlayer, savedShot: LiveMatchShot? = nil)
    case gone
}

struct LiveMatch {
    var team1: LiveMatchTeam
    var team2: LiveMatchTeam
    var pointResults: [LiveMatchPointResult] = []
    
    var allPlayers: [LiveMatchPlayer] { team1.players + team2.players }
    
    var isDoubles: Bool { team1.isDoubles && team2.isDoubles }
    
    var currentGameIndex: Int { team1.scores.count - 1 }
    
    var currentServer: LiveMatchPlayer { allPlayers.first { $0.isServing }! }
    
    var currentServingTeam: LiveMatchTeam {
        team1.players.contains { $0.id == currentServer.id } ? team1 : team2
    }
    
    func player(for id: String) -> LiveMatchPlayer {
        allPlayers.first { $0.id == id }!
    }
    
    func canUndoLastShot() -> Bool {
        // You can only edit a shot within the same game
        return currentGameIndex == pointResults.last?.gameIndex
    }
    
    mutating func startNewGame() {
        team1.scores.append(0)
        team2.scores.append(0)
        
        setServer(playerId: nil)
    }
    
    mutating func pointFinished(with shot: LiveMatchShot) {
        let playerTeam = team1.players.contains { $0.id == shot.playerId } ? team1 : team2
        
        // If it was a winner by the serving team or an error by the receiving team, add a point to the serving team
        // If it was an error by the serving team or a winner by the receiving team, rotate servers
        let scoreResult: LiveMatchPointResult.ScoreResult
        if (shot.result == .winner && playerTeam.isServing) ||
            (shot.result == .error && !playerTeam.isServing) {
            if team1.isServing {
                team1.earnPoint()
                switchSides(isTeam1Intiating: true)
                scoreResult = .team1Point
            } else {
                team2.earnPoint()
                switchSides(isTeam1Intiating: false)
                scoreResult = .team2Point
            }
        } else {
            guard case .serving(let isFirstServer) = currentServer.servingState else { return }
            scoreResult = .sideout(previousServerId: currentServer.id, wasFirstServer: isFirstServer)
            sideout()
            
            // In singles, when a sideout happens, the server's side is based on their score (deuce for an even score, ad for an odd score)
            if !isDoubles {
                if team1.isServing &&
                    ((team1.scores.last! % 2 == 0 && team1.deucePlayer == nil)) ||
                    ((team1.scores.last! % 2 == 1 && team1.adPlayer == nil)) {
                    switchSides(isTeam1Intiating: true)
                } else if team2.isServing &&
                    ((team2.scores.last! % 2 == 0 && team2.deucePlayer == nil)) ||
                    ((team2.scores.last! % 2 == 1 && team2.adPlayer == nil)) {
                    switchSides(isTeam1Intiating: false)
                }
            }
        }
        
        pointResults.append(
            LiveMatchPointResult(
                gameIndex: currentGameIndex,
                shot: shot,
                scoreResult: scoreResult
            )
        )
    }
    
    mutating func sideout() {
        if isDoubles {
            var newServer: (playerId: String?, firstServer: Bool) = (nil, true)
            if case let .serving(isFirstServer) = team1.deucePlayer?.servingState {
                if isFirstServer {
                    newServer = (team1.adPlayer?.id, false)
                } else {
                    newServer = (team2.deucePlayer?.id, true)
                }
            } else if case let .serving(isFirstServer) = team1.adPlayer?.servingState {
                if isFirstServer {
                    newServer = (team1.deucePlayer?.id, false)
                } else {
                    newServer = (team2.deucePlayer?.id, true)
                }
            } else if case let .serving(isFirstServer) = team2.deucePlayer?.servingState {
                if isFirstServer {
                    newServer = (team2.adPlayer?.id, false)
                } else {
                    newServer = (team1.deucePlayer?.id, true)
                }
            } else if case let .serving(isFirstServer) = team2.adPlayer?.servingState {
                if isFirstServer {
                    newServer = (team2.deucePlayer?.id, false)
                } else {
                    newServer = (team1.deucePlayer?.id, true)
                }
            }
            setServer(playerId: newServer.playerId, isFirstServer: newServer.firstServer)
        } else {
            var newServerId: String? = nil
            if team1.deucePlayer?.isServing == true {
                newServerId = team2.deucePlayer?.id
            } else if team1.adPlayer?.isServing == true {
                newServerId = team2.adPlayer?.id
            } else if team2.deucePlayer?.isServing == true {
                newServerId = team1.deucePlayer?.id
            } else if team2.adPlayer?.isServing == true {
                newServerId = team1.adPlayer?.id
            }
            setServer(playerId: newServerId)
        }
    }
    
    mutating func unrotateServer(previousServerId: String, wasFirstServer: Bool) {
        setServer(playerId: previousServerId, isFirstServer: wasFirstServer)
    }
    
    mutating func switchSides(isTeam1Intiating: Bool) {
        if isTeam1Intiating {
            team1.switchSides()
            if !isDoubles {
                team2.switchSides()
            }
        } else {
            team2.switchSides()
            if !isDoubles {
                team1.switchSides()
            }
        }
    }
    
    mutating func switchCourtSides() {
        let tempTeam = team1
        self.team1 = team2
        self.team2 = tempTeam
    }
    
    mutating func setServer(playerId: String?, isFirstServer: Bool = true) {
        team1.deucePlayer?.servingState = .notServing
        team1.adPlayer?.servingState = .notServing
        team2.deucePlayer?.servingState = .notServing
        team2.adPlayer?.servingState = .notServing
        switch playerId {
        case team1.deucePlayer?.id:
            team1.deucePlayer?.servingState = .serving(isFirstServer: isFirstServer)
        case team1.adPlayer?.id:
            team1.adPlayer?.servingState = .serving(isFirstServer: isFirstServer)
        case team2.deucePlayer?.id:
            team2.deucePlayer?.servingState = .serving(isFirstServer: isFirstServer)
        case team2.adPlayer?.id:
            team2.adPlayer?.servingState = .serving(isFirstServer: isFirstServer)
        default: break
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
            stats: pointResults.compactMap {
                return Stat(
                    playerId: $0.shot.playerId,
                    gameIndex: $0.gameIndex,
                    shotType: $0.shot.type,
                    shotResult: $0.shot.result,
                    shotSide: $0.shot.side
                )
            }
        )
    }
}

struct LiveMatchTeam {
    var deucePlayer: LiveMatchPlayer?
    var adPlayer: LiveMatchPlayer?
    var scores: [Int] = [0]
    
    var players: [LiveMatchPlayer] { [deucePlayer, adPlayer].compactMap { $0 } }
    var isServing: Bool { players.contains { $0.isServing } }
    var isDoubles: Bool { deucePlayer != nil && adPlayer != nil }
    
    mutating func earnPoint() {
        scores[scores.count - 1] += 1
    }
    
    mutating func losePoint() {
        scores[scores.count - 1] -= 1
    }
    
    mutating func switchSides() {
        let tempPlayer = deucePlayer
        self.deucePlayer = adPlayer
        self.adPlayer = tempPlayer
    }
}

struct LiveMatchPlayer {
    var player: Player
    
    var id: String { player.id }
    var firstName: String { player.firstName }
    
    var servingState: ServingState = .notServing
    
    var isServing: Bool {
        switch servingState {
        case .notServing: return false
        case .serving(_): return true
        }
    }
    
    enum ServingState {
        case notServing
        case serving(isFirstServer: Bool = true)
    }
}

struct LiveMatchPointResult {
    let gameIndex: Int
    let shot: LiveMatchShot
    var scoreResult: ScoreResult
    
    enum ScoreResult {
        case team1Point
        case team2Point
        case sideout(previousServerId: String, wasFirstServer: Bool)
    }
}

struct LiveMatchShot {
    let playerId: String
    let type: Stat.ShotType
    let result: Stat.Result
    let side: Stat.ShotSide?
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

#if DEBUG
struct LiveMatchView_Previews: PreviewProvider {
    static var previews: some View {
        LiveMatchView(
            team1: [Player.eric],//, Player.jessica],
            team2: [Player.bryan]//, Player.bob]
        ) {
            print("Saved")
        }
        .environmentObject(MatchesViewModel(repository: TestRepository(), loginManager: TestLoginManager()))
    }
}
#endif
