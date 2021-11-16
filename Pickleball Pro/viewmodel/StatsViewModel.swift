//
//  StatsViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 10/30/21.
//

import Foundation

class StatsViewModel: BaseViewModel<StatsViewState> {
    // TODO: Implement caching at the repo level
    private var matches: [Match]? = nil {
        didSet { updateStateIfReady() }
    }
    private var me: Player? = nil {
        didSet { updateStateIfReady() }
    }
    var filter: StatsFilter = .all {
        didSet { updateStateIfReady() }
    }
    
    func load() {
        guard loginManager.isLoggedIn else {
            state.loggedOut()
            return
        }
        
        state.startLoad()
        repository.loadMatches {
            switch $0 {
            case .success(let matches):
                self.matches = matches
            case .failure(let error):
                self.state.receivedFailure(.loadMatchesError(afError: error))
            }
        }
        repository.loadPlayers {
            switch $0 {
            case .success(let players):
                guard let me = players.first(where: { $0.isOwner }) else {
                    self.state.receivedFailure(.loadPlayersError(afError: nil))
                    return
                }
                self.me = me
            case .failure(let error):
                self.state.receivedFailure(.loadPlayersError(afError: error))
            }
        }
    }
    
    override func loginChanged(isLoggedIn: Bool) {
        if isLoggedIn {
            load()
        } else {
            state.loggedOut()
        }
    }
    
    private func updateStateIfReady() {
        if var matches = matches, let me = me {
            if filter != .all {
                matches = matches.filter { (filter == .doubles) == $0.isDoubles }
            }
            
            
            let (wins, losses, ties) = matches.record(for: me)
            self.state = .success(StatsViewState(wins: wins, losses: losses, ties: ties))
            // TODO: Determine time period based off of match dispertion
//            let monthlyRecord: [(String, Double)] = Dictionary(grouping: matches, by: { "\($0.date.get(.month))-\($0.date.get(.year))" }).map {
//                let (wins, losses, ties) = $1.record(for: me)
//                return ($0, Double(wins) / Double(wins + losses + ties))
//            }
//            self.state = .success(StatsViewState(wins: wins, losses: losses, ties: ties, recordOverTime: monthlyRecord))
        }
    }
}

private extension Array where Element == Match {
    func record(for player: Player) -> (Int, Int, Int) {
        return self.reduce((0, 0, 0)) { soFar, match in
            let (wins, losses, ties) = soFar
            switch match.result(for: player) {
            case .win: return (wins + 1, losses, ties)
            case .loss: return (wins, losses + 1, ties)
            case .tie: return (wins, losses, ties + 1)
            case .didNotPlay: return soFar
            }
        }
    }
}

enum StatsFilter: String, CaseIterable {
    case all = "All Matches"
    case singles = "Singles"
    case doubles = "Doubles"
}

enum PlayerMatchResult {
    case win
    case loss
    case tie
    case didNotPlay
}

extension Match {
    func result(for player: Player) -> PlayerMatchResult {
        guard (team1 + team2).contains(player) else {
            return .didNotPlay
        }
        let (team1GamesWon, team2GamesWon) = scores.reduce((0, 0)) { soFar, game in
            let (team1, team2) = soFar
            if game.team1Score > game.team2Score {
                return (team1 + 1, team2)
            } else if game.team1Score < game.team2Score {
                return (team1, team2 + 1)
            } else {
                return soFar
            }
        }
        if team1GamesWon > team2GamesWon {
            return team1.contains(player) ? .win : .loss
        } else if team1GamesWon < team2GamesWon {
            return team2.contains(player) ? .win : .loss
        } else {
            return .tie
        }
    }
}

struct StatsViewState {
    let wins: Int
    let losses: Int
    let ties: Int
//    let recordOverTime: [(String, Double)]?
}
