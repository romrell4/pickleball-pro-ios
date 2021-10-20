//
//  StackedRoundImageViews.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import SwiftUI

struct StackedRoundImageViews: View {
    let size: CGFloat
    let player1: Player
    let player2: Player
    
    var offset: CGFloat { size / 5 }
    
    var body: some View {
        ZStack {
            player1.image()
                .offset(x: -offset, y: -offset)
                .frame(width: size, height: size)
            player2.image()
                .offset(x: offset, y: offset)
                .frame(width: size, height: size)
        }
    }
}

struct StackedRoundImageViews_Previews: PreviewProvider {
    static var previews: some View {
        StackedRoundImageViews(
            size: 80,
            player1: Player.eric,
            player2: Player.jessica
        )
    }
}
