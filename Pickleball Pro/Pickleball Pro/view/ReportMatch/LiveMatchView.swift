//
//  LiveMatchView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/11/21.
//

import SwiftUI

struct LiveMatchView: View {
    @State var modalIsDisplayed = false
    @State var savedShot: Stat.Shot?
    
    var body: some View {
        ZStack {
            VStack {
                Button("Tap to Report a Stat!") {
                    modalIsDisplayed.toggle()
                }
                if let shot = savedShot {
                    Text(shot.type.rawValue)
                    Text(shot.result.rawValue)
                    if let side = shot.side {
                        Text(side.rawValue)
                    }
                }
            }
            if modalIsDisplayed {
                ZStack {
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .onTapGesture {
                            modalIsDisplayed = false
                        }
                    StatTracker(shot: $savedShot) {
                        modalIsDisplayed = false
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20).fill(Color.white)
                    )
                }
            }
        }
    }
}

struct LiveMatchView_Previews: PreviewProvider {
    static var previews: some View {
        LiveMatchView()
    }
}
