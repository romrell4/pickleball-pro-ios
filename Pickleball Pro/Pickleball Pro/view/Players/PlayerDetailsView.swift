//
//  PlayerDetailsView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/25/21.
//

import SwiftUI

struct PlayerDetailsView: View {
    @EnvironmentObject var playersViewModel: PlayersViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    private let originalPlayer: Player
    @State private var player: PlayerDetails
    
    init(player: Player) {
        self.originalPlayer = player
        _player = State(initialValue: PlayerDetails(player: player))
    }
    
    var body: some View {
        VStack {
            RoundImageView(url: player.imageUrl)
                .frame(width: 150, height: 150)
                .padding(.vertical, 10)
                .onTapGesture {
                    // TODO: Allow edit
                }
            HStack(spacing: 20) {
                ImageButton(data: player.email, systemImageName: "envelope") { email in
                    guard let url = URL(string: "mailto:\(email)") else { return }
                    UIApplication.shared.open(url)
                }
                ImageButton(data: player.phoneNumber, systemImageName: "phone") { phoneNumber in
                    guard let url = URL(string: "tel://\(phoneNumber)") else { return }
                    UIApplication.shared.open(url)
                }
                ImageButton(data: player.phoneNumber, systemImageName: "message") { phoneNumber in
                    guard let url = URL(string: "sms://\(phoneNumber)") else { return }
                    UIApplication.shared.open(url)
                }
            }
            List {
                Section(header: Text("Name")) {
                    TextRow(hint: "First Name", value: $player.firstName)
                    TextRow(hint: "Last Name", value: $player.lastName)
                }
                Section(header: Text("Contact Info")) {
                    TextRow(hint: "Phone Number", value: $player.phoneNumber)
                    TextRow(hint: "Email Address", value: $player.email)
                }
                Section {
                    Picker("Dominant Hand", selection: $player.dominantHand) {
                        ForEach(PlayerDetails.Hand.allCases, id: \.self) {
                            Text($0.rawValue.capitalized).tag($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Notes")) {
                    MultilineTextRow(value: $player.notes)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("Save") {
                playersViewModel.update(player: player.toPlayer(originalPlayer: originalPlayer)) {
                    if case .success = $0 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        )
        .background(Color(.systemGroupedBackground))
        .navigationBarTitle(originalPlayer.fullName)
    }
}

private struct ImageButton: View {
    var data: String
    var systemImageName: String
    var action: (String) -> Void
    
    var body: some View {
        Button(action: {
            action(data)
        }) {
            Image(systemName: systemImageName)
                .foregroundColor(.white)
                .padding(15)
                .background(Circle())
        }
        .disabled(data == "")
    }
}

private struct TextRow: View {
    var hint: String
    @Binding var value: String
    
    var body: some View {
        HStack {
            TextField(hint, text: $value)
        }
    }
}

private struct MultilineTextRow: View {
    @Binding var value: String
    
    var body: some View {
        HStack {
            TextEditor(text: $value)
        }
    }
}

private struct PlayerDetails {
    var firstName: String
    var lastName: String
    var imageUrl: String
    var dominantHand: Hand
    var level: Double
    var phoneNumber: String
    var email: String
    var notes: String
    
    enum Hand : String, Equatable, CaseIterable {
        case left
        case right
        case unknown
        
        init(hand: Player.Hand?) {
            switch hand {
            case .left:
                self = .left
            case .right:
                self = .right
            default:
                self = .unknown
            }
        }
        
        func toPlayerHand() -> Player.Hand? {
            switch self {
            case .left:
                return .left
            case .right:
                return .right
            case .unknown:
                return nil
            }
        }
    }
    
    init(player: Player) {
        self.firstName = player.firstName
        self.lastName = player.lastName
        self.imageUrl = player.imageUrl
        self.dominantHand = Hand(hand: player.dominantHand)
        self.level = player.level ?? 0
        self.phoneNumber = player.phoneNumber ?? ""
        self.email = player.email ?? ""
        self.notes = player.notes
    }
    
    func toPlayer(originalPlayer: Player) -> Player {
        Player(
            id: originalPlayer.id,
            firstName: firstName,
            lastName: lastName,
            imageUrl: imageUrl,
            dominantHand: dominantHand.toPlayerHand(),
            level: level == 0 ? nil : level,
            phoneNumber: phoneNumber == "" ? nil : phoneNumber,
            email: email == "" ? nil : email,
            notes: notes
        )
    }
}

struct PlayerDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlayerDetailsView(player: Player.eric)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
