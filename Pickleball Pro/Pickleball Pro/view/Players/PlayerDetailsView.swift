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
    @Binding var player: Player
    
    var body: some View {
        VStack {
            RoundImageView(url: player.imageUrl)
                .frame(width: 150, height: 150)
                .padding(.top, 10)
                .onTapGesture {
                    // TODO: Allow edit
                }
            List {
                Section {
                    RowView(hint: "First Name", value: $player.firstName)
                    RowView(hint: "Last Name", value: $player.lastName)
                }
                Section {
                    RowView(hint: "Phone Number", value: $player.editablePhoneNumber)
                    RowView(hint: "Email Address", value: $player.editableEmail)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button("Save") {
            playersViewModel.update(player: player) { _ in
                presentationMode.wrappedValue.dismiss()
            }
        })
        .background(Color(.systemGroupedBackground))
        .navigationBarTitle(player.fullName)
    }
}

private struct RowView: View {
    var hint: String
    @Binding var value: String
    
    var body: some View {
        HStack {
            TextField(hint, text: $value)
        }
    }
}

struct PlayerDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlayerDetailsView(player: .constant(Player.eric))
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
