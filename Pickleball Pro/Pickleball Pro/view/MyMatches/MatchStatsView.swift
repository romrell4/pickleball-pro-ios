//
//  MatchStatsView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/4/21.
//

import SwiftUI

enum Selection {
    case selected(color: Color = Color.clear)
    case deselected
    
    var isSelected: Bool {
        switch self {
        case .selected: return true
        case .deselected: return false
        }
    }
    
    var color: Color {
        switch self {
        case .selected(let selectedColor): return selectedColor
        case .deselected: return Color.clear
        }
    }
    
    mutating func toggle() {
        switch self {
        case .selected: self = .deselected
        case .deselected: self = .selected()
        }
    }
}

struct MatchStatsView: View {
    var match: Match
    
    @State private var gameFilterIndex = 0
    
    @State private var team1Player1Selection: Selection = .selected()
    @State private var team1Player2Selection: Selection = .selected()
    @State private var team2Player1Selection: Selection = .selected()
    @State private var team2Player2Selection: Selection = .selected()
    
    private var allPlayerSelections: [(Binding<Selection>, Player?)] {
        [
            ($team1Player1Selection, match.team1[safe: 0]),
            ($team1Player2Selection, match.team1[safe: 1]),
            ($team2Player1Selection, match.team2[safe: 0]),
            ($team2Player2Selection, match.team2[safe: 1]),
        ]
    }
    
    private var playersBeingCompared: [Player]? {
        // Basically, if not all are selected
        let selectedPlayers = allPlayerSelections.filter { $0.0.wrappedValue.isSelected }
        
        // If we haven't selected everyone, return the selected players
        if selectedPlayers.count != allPlayerSelections.count {
            return selectedPlayers.compactMap { $0.1 }
        } else {
            return nil
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            let filters = ["Match"] + match.scores.indices.map { "Game \($0 + 1)" }
            Picker("Game Filter", selection: $gameFilterIndex) {
                ForEach(filters.indices) { index in
                    Text(filters[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.bottom)
            
            HStack {
                Spacer()
                UnderlinedImage(
                    url: match.team1[0].imageUrl,
                    selectionBinding: $team1Player1Selection
                ) {
                    if match.isDoubles {
                        playerTapped($0)
                    }
                }
                if match.isDoubles {
                    UnderlinedImage(
                        url: match.team1[1].imageUrl,
                        selectionBinding: $team1Player2Selection
                    ) {
                        playerTapped($0)
                    }
                }
                Spacer()
                Spacer()
                UnderlinedImage(
                    url: match.team2[0].imageUrl,
                    selectionBinding: $team2Player1Selection
                ) {
                    if match.isDoubles {
                        playerTapped($0)
                    }
                }
                if match.isDoubles {
                    UnderlinedImage(
                        url: match.team2[1].imageUrl,
                        selectionBinding: $team2Player2Selection
                    ) {
                        playerTapped($0)
                    }
                }
                Spacer()
            }
            
            ScrollView {
                ForEach(
                    match.statGroupings(
                        gameIndex: gameFilterIndex > 0 ? gameFilterIndex - 1 : nil,
                        playerIds: playersBeingCompared?.map { $0.id }
                    ),
                    id: \.self
                ) {
                    StatView(statGrouping: $0)
                        .frame(height: 35)
                        .padding(.horizontal, 8)
                }
                .padding()
            }
        }
    }
    
    private func playerTapped(_ binding: Binding<Selection>) {
        // If everyone is already selected, we're entering a selection process. Deselect everyone before toggling
        if allPlayerSelections.allSatisfy({ $0.0.wrappedValue.isSelected }) {
            allPlayerSelections.forEach {
                $0.0.wrappedValue = .deselected
            }
        }
        
        binding.wrappedValue.toggle()
        
        // If we now have none selected or 3 selected, select everyone again
        if [0, 3].contains(allPlayerSelections.filter({ $0.0.wrappedValue.isSelected }).count) {
            allPlayerSelections.forEach {
                $0.0.wrappedValue = .selected()
            }
        } else {
            fixColors()
        }
    }
    
    private func fixColors() {
        var colors = [
            Color.red.opacity(0.25),
            Color.blue.opacity(0.25),
        ]
        for playerSelection in allPlayerSelections {
            if playerSelection.0.wrappedValue.isSelected {
                playerSelection.0.wrappedValue = Selection.selected(color: colors.isEmpty ? Color.clear : colors.removeFirst())
            }
        }
    }
}

struct UnderlinedImage: View {
    let url: String
    let selectionBinding: Binding<Selection>
    let onTap: (Binding<Selection>) -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            RoundImageView(url: url)
                .frame(width: 30, height: 30)
                .opacity(selectionBinding.wrappedValue.isSelected ? 1 : 0.5)
            Rectangle()
                .fill(selectionBinding.wrappedValue.color)
                .frame(width: 30, height: 2)
        }
        .onTapGesture {
            onTap(selectionBinding)
        }
    }
}

struct MatchStatsView_Previews: PreviewProvider {
    static var previews: some View {
        MatchStatsView(match: Match.doubles)
    }
}
