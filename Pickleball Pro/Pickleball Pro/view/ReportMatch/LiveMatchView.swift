//
//  LiveMatchView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/11/21.
//

import SwiftUI

struct LiveMatchView: View {
    @EnvironmentObject var matchesViewModel: MatchesViewModel
    @Environment(\.presentationMode) var presentationMode
    @AppStorage(PreferenceKeys.autoSwitchSides) var autoSwitchSides = false
    @AppStorage(PreferenceKeys.liveMatchConfirmations) var requireConfirmations = true
    @State private var match: LiveMatch
    @State private var statTrackerModalState: StatTrackerModalState = .gone
    @State private var selectServerModalVisible: Bool = true
    @State private var alert: ProAlert? = nil
    @State private var matchStatsModalVisible: Bool = false
    
    var onMatchSaved: () -> Void
    
    init?(players: ([Player], [Player]), onMatchSaved: @escaping () -> Void) {
        guard players.0.count > 0 && players.1.count > 0 else { return nil }
        _match = State(initialValue: LiveMatch(
            team1: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(
                    player: players.0[0]
                    //,servingState: .serving(isFirstServer: players.0.count == 1)
                ),
                adPlayer: LiveMatchPlayer(player: players.0[safe: 1])
            ),
            team2: LiveMatchTeam(
                deucePlayer: LiveMatchPlayer(player: players.1[0]),
                adPlayer: LiveMatchPlayer(player: players.1[safe: 1])
            )
        ))
        self.onMatchSaved = onMatchSaved
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("liveMatchBackground"))
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
                            match.pointFinished(with: shot, by: player)
                        }
                        statTrackerModalState = .gone
                    }
                }
            case .gone: EmptyView()
            }
            if selectServerModalVisible {
                ModalView(onDismiss: {}) {
                    SelectServerModal(
                        team1: $match.team1,
                        team2: $match.team2
                    ) { player in
                        selectServerModalVisible = false
                        
                        // If they selected a "player2", switch sides
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
                    Button("Switch Court Sides") {
                        match.switchCourtSides()
                    }
                    if match.canUndoLastShot() {
                        Button("Undo Last Shot") {
                            if let stat = match.stats.popLast() {
                                switch stat.scoreResult {
                                case .team1Point:
                                    match.team1.losePoint()
                                    match.switchSides(isTeam1Intiating: true)
                                case .team2Point:
                                    match.team2.losePoint()
                                    match.switchSides(isTeam1Intiating: false)
                                case .sideout(let previousServerId, let wasFirstServer):
                                    match.unrotateServer(previousServerId: previousServerId, wasFirstServer: wasFirstServer)
                                }
                                statTrackerModalState = .visible(player: match.player(for: stat.stat.playerId), savedShot: stat.stat.shot)
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
    
    private let pickleballImage: some View = Image("pickleball")
        .resizable()
        .frame(width: 20, height: 20)
    
    var body: some View {
        if let player = player {
            HStack(spacing: 4) {
                player.player.image()
                    .frame(width: 50, height: 50)
                    .onTapGesture {
                        statTrackerModalState = .visible(player: player)
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
                                    ScoreView(score: $match.team1.scores[index])
                                        .padding(.bottom, 15)
                                    ScoreView(score: $match.team2.scores[index])
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
    @Binding var score: Int
    
    var body: some View {
        GroupBox {
            Text("\(score)").frame(width: 22)
        }.onTapGesture {
            score += 1
        }
    }
}

private enum StatTrackerModalState {
    case visible(player: LiveMatchPlayer, savedShot: Stat.Shot? = nil)
    case gone
}

struct LiveMatch {
    var team1: LiveMatchTeam
    var team2: LiveMatchTeam
    var stats: [LiveMatchStat] = []
    
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
        return currentGameIndex == stats.last?.stat.gameIndex
    }
    
    mutating func startNewGame() {
        team1.scores.append(0)
        team2.scores.append(0)
        
        resetServer()
    }
    
    mutating func pointFinished(with shot: Stat.Shot, by player: LiveMatchPlayer) {
        let playerTeam = team1.players.contains { $0.id == player.id } ? team1 : team2
        
        // If it was a winner by the serving team or an error by the receiving team, add a point to the serving team
        // If it was an error by the serving team or a winner by the receiving team, rotate servers
        let scoreResult: LiveMatchStat.ScoreResult
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
            rotateServer()
        }
        
        stats.append(
            LiveMatchStat(
                stat: Stat(
                    playerId: player.id,
                    gameIndex: currentGameIndex,
                    shotType: shot.type,
                    shotResult: shot.result,
                    shotSide: shot.side
                ),
                scoreResult: scoreResult
            )
        )
    }
    
    mutating func rotateServer() {
        if isDoubles {
            switch team1.deucePlayer?.servingState {
            case .serving(let isFirstServer):
                if isFirstServer {
                    team1.adPlayer?.servingState = .serving(isFirstServer: false)
                } else {
                    team2.deucePlayer?.servingState = .serving(isFirstServer: true)
                }
                team1.deucePlayer?.servingState = .notServing
                return
            default: break
            }
            
            switch team1.adPlayer?.servingState {
            case .serving(let isFirstServer):
                if isFirstServer {
                    team1.deucePlayer?.servingState = .serving(isFirstServer: false)
                } else {
                    team2.deucePlayer?.servingState = .serving(isFirstServer: true)
                }
                team1.adPlayer?.servingState = .notServing
                return
            default: break
            }
            
            switch team2.deucePlayer?.servingState {
            case .serving(let isFirstServer):
                if isFirstServer {
                    team2.adPlayer?.servingState = .serving(isFirstServer: false)
                } else {
                    team1.deucePlayer?.servingState = .serving(isFirstServer: true)
                }
                team2.deucePlayer?.servingState = .notServing
                return
            default: break
            }
            
            switch team2.adPlayer?.servingState {
            case .serving(let isFirstServer):
                if isFirstServer {
                    team2.deucePlayer?.servingState = .serving(isFirstServer: false)
                } else {
                    team1.deucePlayer?.servingState = .serving(isFirstServer: true)
                }
                team2.adPlayer?.servingState = .notServing
                return
            default: break
            }
        } else {
            if team1.deucePlayer?.isServing == true {
                team2.deucePlayer?.servingState = .serving()
                team1.deucePlayer?.servingState = .notServing
            } else if team1.adPlayer?.isServing == true {
                team2.adPlayer?.servingState = .serving()
                team1.adPlayer?.servingState = .notServing
            } else if team2.deucePlayer?.isServing == true {
                team1.deucePlayer?.servingState = .serving()
                team2.deucePlayer?.servingState = .notServing
            } else if team2.adPlayer?.isServing == true {
                team1.adPlayer?.servingState = .serving()
                team2.adPlayer?.servingState = .notServing
            }
        }
    }
    
    mutating func unrotateServer(previousServerId: String, wasFirstServer: Bool) {
        resetServer()
        
        switch previousServerId {
        case team1.deucePlayer?.id:
            team1.deucePlayer?.servingState = .serving(isFirstServer: wasFirstServer)
        case team1.adPlayer?.id:
            team1.adPlayer?.servingState = .serving(isFirstServer: wasFirstServer)
        case team2.deucePlayer?.id:
            team2.deucePlayer?.servingState = .serving(isFirstServer: wasFirstServer)
        case team2.adPlayer?.id:
            team2.adPlayer?.servingState = .serving(isFirstServer: wasFirstServer)
        default:
            break
        }
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
    
    func toMatch() -> Match {
        Match(
            id: "",
            date: Date(),
            team1: team1.players.map { $0.player },
            team2: team2.players.map { $0.player },
            scores: zip(team1.scores, team2.scores)
                .map { GameScore(team1Score: $0.0, team2Score: $0.1) },
            stats: stats.map { $0.stat }
        )
    }
    
    private mutating func resetServer() {
        team1.deucePlayer?.servingState = .notServing
        team1.adPlayer?.servingState = .notServing
        team2.deucePlayer?.servingState = .notServing
        team2.adPlayer?.servingState = .notServing
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

struct LiveMatchStat {
    let stat: Stat
    let scoreResult: ScoreResult
    
    enum ScoreResult {
        case team1Point
        case team2Point
        case sideout(previousServerId: String, wasFirstServer: Bool)
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
            LiveMatchView(players: ([Player.eric, Player.jessica], [Player.bryan, Player.bob])) {
                print("Saved")
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .preferredColorScheme(.dark)
        }
        .environmentObject(MatchesViewModel(repository: TestRepository()))
    }
}
