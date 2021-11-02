//
//  PlayerView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/25/21.
//

import SwiftUI

struct PlayerSummaryView: View {
    var player: Player
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                player.image()
                    .frame(width: 60, height: 60)
                VStack(alignment: .leading) {
                    Text(player.fullName)
                        .font(.title3)
                    if let level = player.level {
                        Text("Level: \(String(format: "%.1f", level))")
                            .font(.caption)
                    }
                    if let hand = player.dominantHand {
                        Text("Dominant Hand: \(hand.rawValue.capitalized)")
                            .font(.caption)
                    }
                }
                Spacer()
            }
            if let notes = player.notes, !notes.isEmpty {
                Text("Notes: \(notes)")
                    .font(.caption)
                    .lineLimit(3)
            }
        }
    }
}

#if DEBUG
struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerSummaryView(player: Player.eric)
    }
}
#endif
