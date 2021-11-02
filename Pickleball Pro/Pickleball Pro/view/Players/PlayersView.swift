//
//  PlayersView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import SwiftUI

struct PlayersView: View {
    @EnvironmentObject var viewModel: PlayersViewModel
    @ObservedObject private var loginManager = LoginManager.instance
    @State private var showingAddPlayerSheet = false
    @AppStorage(PreferenceKeys.playerSortDirection) fileprivate var sortDirectionAsc: Bool = true
    @AppStorage(PreferenceKeys.playerSortOption) fileprivate var selectedSort: PlayerSortOption = .firstName
    @State private var searchFilter = ""
    
    var body: some View {
        NavigationView {
            DefaultStateView(state: viewModel.state) {
                let players = $0
                    .filter { $0.matches(filter: searchFilter) }
                    .sorted(by: playerSorter)
                let list = List {
                    ForEach(players, id: \.id) { player in
                        NavigationLink(destination: PlayerDetailsView(player: player)) {
                            PlayerSummaryView(player: player)
                                .padding(.vertical, 8)
                        }.deleteDisabled(player.isOwner)
                    }
                    .onDelete {
                        let player = players[$0[$0.startIndex]]
                        viewModel.delete(player: player)
                    }
                }
                if #available(iOS 15.0, *) {
                    list.searchable(text: $searchFilter).refreshable {
                        viewModel.load()
                    }
                } else {
                    list
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Image(systemName: sortDirectionAsc ? "arrow.down" : "arrow.up")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            sortDirectionAsc.toggle()
                        }
                    Picker("Select a sort option", selection: $selectedSort) {
                        ForEach(PlayerSortOption.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "plus.circle")
                        .disabled(!loginManager.isLoggedIn)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            showingAddPlayerSheet = true
                        }
                }
            }
            .sheet(isPresented: $showingAddPlayerSheet) {
                NavigationView {
                    PlayerDetailsView(player: nil)
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
    
    private var playerSorter: (Player, Player) -> Bool {
        { lhs, rhs in
            switch selectedSort {
            case .firstName:
                if lhs.firstName.isEmpty {
                    return false
                } else if rhs.firstName.isEmpty {
                    return true
                }
                return sortDirectionAsc ? lhs.firstName < rhs.firstName : lhs.firstName > rhs.firstName
            case .lastName:
                if lhs.lastName.isEmpty {
                    return false
                } else if rhs.lastName.isEmpty {
                    return true
                }
                return sortDirectionAsc ? lhs.lastName < rhs.lastName : lhs.lastName > rhs.lastName
            case .level:
                let bottom = sortDirectionAsc ? 0 : Double.greatestFiniteMagnitude
                let leftLevel = lhs.level ?? bottom
                let rightLevel = rhs.level ?? bottom
                // This is reversed from the others, simply because Bryan wanted the default to be highest ranked at the top (but wanted the names to still default to the "lowest" letter on top
                return sortDirectionAsc ? leftLevel > rightLevel : leftLevel < rightLevel
            }
        }
    }
}

private enum SortDirection {
    case asc
    case desc
}

private enum PlayerSortOption: String, CaseIterable {
    case firstName = "First Name"
    case lastName = "Last Name"
    case level = "Level"
}

private extension Player {
    func matches(filter: String) -> Bool {
        let searchableFields = [firstName, lastName, notes].compactMap { $0 }
        return filter.isEmpty || searchableFields.contains { $0.range(of: filter, options: .caseInsensitive) != nil }
    }
}

#if DEBUG
struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView()
            .environmentObject(PlayersViewModel(repository: TestRepository()))
    }
}
#endif
