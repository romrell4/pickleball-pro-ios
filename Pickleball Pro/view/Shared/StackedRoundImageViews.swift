//
//  StackedRoundImageViews.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import SwiftUI

struct StackedRoundImageViews: View {
    let size: CGFloat
    let player1: Player?
    let player2: Player?
    
    private var offset: CGFloat { size / 8 }
    private var eachSize: CGFloat { size - offset * 2 }
    
    var body: some View {
        ZStack {
            if let player1 = player1, let player2 = player2 {
                player1.image()
                    .offset(x: -offset, y: -offset)
                    .frame(width: eachSize, height: eachSize)
                player2.image()
                    .offset(x: offset, y: offset)
                    .frame(width: eachSize, height: eachSize)
            } else {
                player1?.image().frame(width: size, height: size)
                player2?.image().frame(width: size, height: size)
            }
        }.frame(width: size, height: size)
    }
}

#if DEBUG
struct StackedRoundImageViews_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            StackedRoundImageViews(
                size: 80,
                player1: Player.eric,
                player2: Player.jessica
            )
            StackedRoundImageViews(size: 80, player1: Player.eric, player2: nil)
        }
    }
}
#endif
