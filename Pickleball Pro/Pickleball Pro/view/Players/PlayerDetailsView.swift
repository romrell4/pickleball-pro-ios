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
    private let originalPlayer: Player?
    private let onPlayerSaved: (Player) -> Void
    @State private var player: PlayerDetails
    @State private var firstNameValidationError = false
    
    init(player: Player?, onPlayerSaved: @escaping (Player) -> Void = {_ in}) {
        self.originalPlayer = player
        self.onPlayerSaved = onPlayerSaved
        _player = State(initialValue: PlayerDetails(player: player))
    }
    
    var body: some View {
        List {
            if let originalPlayer = originalPlayer {
                // Put it in a header to get rid of the background color
                Section(header: VStack {
                    HStack {
                        Spacer()
                        originalPlayer.image()
                            .frame(width: 100, height: 100)
                            .padding(.vertical, 10)
                            // POST-MVP: Allow photo upload
                            //.onTapGesture {}
                        Spacer()
                    }
                    HStack(spacing: 20) {
                        Spacer()
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
                        Spacer()
                    }
                }) {}
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            Section(header: Text("Name")) {
                TextRow(hint: "First Name (Required)", value: $player.firstName, hasValidationError: firstNameValidationError)
                TextRow(hint: "Last Name", value: $player.lastName)
            }
            Section(header: Text("Contact Info")) {
                TextRow(hint: "Phone Number", value: $player.phoneNumber, keyboardType: .phonePad)
                TextRow(hint: "Email Address", value: $player.email, keyboardType: .emailAddress, capitalization: .none)
            }
            Section {
                Picker("Dominant Hand", selection: $player.dominantHand) {
                    ForEach(PlayerDetails.Hand.allCases, id: \.self) {
                        Text($0.rawValue.capitalized).tag($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                LevelRow(level: $player.level)
            }
            Section(header: Text("Notes")) {
                MultilineTextRow(value: $player.notes)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("Save") {
                do {
                    let newPlayer = try player.toPlayer(originalId: originalPlayer?.id)
                    let onSave: (Player) -> Void = {
                        self.onPlayerSaved($0)
                        presentationMode.wrappedValue.dismiss()
                    }
                    if originalPlayer != nil {
                        playersViewModel.update(player: newPlayer, callback: onSave)
                    } else {
                        playersViewModel.create(player: newPlayer, callback: onSave)
                    }
                } catch SavePlayerError.noFirstName {
                    firstNameValidationError = true
                } catch {}
            }
        )
        .background(Color(.systemGroupedBackground))
        .navigationBarTitle(originalPlayer?.fullName ?? "New Player")
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
    let hint: String
    @Binding var value: String
    var hasValidationError: Bool = false
    var keyboardType: UIKeyboardType = .default
    var capitalization: UITextAutocapitalizationType = .sentences
    
    var body: some View {
        TextField("", text: $value)
            .placeholder(when: value.isEmpty) {
                Text(hint).foregroundColor(hasValidationError ? .red : .gray)
            }
            .keyboardType(keyboardType)
            .autocapitalization(capitalization)
    }
}

private struct LevelRow: View {
    @Binding var level: Double
    
    var body: some View {
        VStack {
            Slider(value: $level, in: 0...6, step: 0.1) {
                Text("Label")
            }
            
            Text(String(format: "Level: %.1f", level))
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
    var imageUrl: String?
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
    
    init(player: Player?) {
        if let player = player {
            self.firstName = player.firstName
            self.lastName = player.lastName
            self.imageUrl = player.imageUrl
            self.dominantHand = Hand(hand: player.dominantHand)
            self.level = player.level ?? 0
            self.phoneNumber = player.phoneNumber ?? ""
            self.email = player.email ?? ""
            self.notes = player.notes ?? ""
        } else {
            self.firstName = ""
            self.lastName = ""
            self.imageUrl = nil
            self.dominantHand = Hand.unknown
            self.level = 0
            self.phoneNumber = ""
            self.email = ""
            self.notes = ""
        }
    }
    
    func toPlayer(originalId: String?) throws -> Player {
        if firstName == "" {
            throw SavePlayerError.noFirstName
        }
        return Player(
            id: originalId ?? "",
            firstName: firstName,
            lastName: lastName,
            imageUrl: imageUrl,
            dominantHand: dominantHand.toPlayerHand(),
            level: level == 0 ? nil : level,
            phoneNumber: phoneNumber == "" ? nil : phoneNumber,
            email: email == "" ? nil : email,
            notes: notes == "" ? nil : notes
        )
    }
}

extension PlayerDetails: PlayerImagable {
    var _firstName: String? { firstName }
    var _lastName: String? { lastName }
}

private enum SavePlayerError: Error {
    case noFirstName
}

private extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#if DEBUG
struct PlayerDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlayerDetailsView(player: Player.bob)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#endif
