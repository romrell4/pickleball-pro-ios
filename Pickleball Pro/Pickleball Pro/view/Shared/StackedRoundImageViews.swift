//
//  StackedRoundImageViews.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import SwiftUI

struct StackedRoundImageViews: View {
    let size: CGFloat
    let url1: String
    let url2: String
    
    var offset: CGFloat { size / 5 }
    
    var body: some View {
        ZStack {
            RoundImageView(url: url1)
                .offset(x: -offset, y: -offset)
                .frame(width: size, height: size)
            RoundImageView(url: url2)
                .offset(x: offset, y: offset)
                .frame(width: size, height: size)
        }
    }
}

struct StackedRoundImageViews_Previews: PreviewProvider {
    static var previews: some View {
        StackedRoundImageViews(
            size: 80,
            url1: Player.eric.imageUrl,
            url2: Player.jessica.imageUrl
        )
    }
}
