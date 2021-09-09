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
                RoundImageView(url: player.imageUrl)
                    .frame(width: 60, height: 60)
                VStack(alignment: .leading) {
                    Text(player.fullName)
                        .font(.title3)
                    if let level = player.level {
                        // TODO: Use stars?
                        Text("Level: \(String(format: "%.1f", level))")
                            .font(.caption)
                    }
                    if let hand = player.dominantHand {
                        // TODO: Make this a segmented view?
                        Text("Dominant Hand: \(hand.rawValue.capitalized)")
                            .font(.caption)
                    }
                }
                Spacer()
            }
            if !player.notes.isEmpty {
                Text("Notes: \(player.notes)")
                    .font(.caption)
                    .lineLimit(3)
            }
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerSummaryView(player: Player.eric)
    }
}
