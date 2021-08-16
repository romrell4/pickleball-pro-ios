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
        GeometryReader { fullScreen in
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.75))
                HStack {
                    // TODO: Display score
//                    VStack {
//                        GroupBox {
//                            Text("7")
//                        }
//                        GroupBox {
//                            Text("4")
//                        }
//                    }
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            RoundImageView(url: Player.eric.imageUrl)
                                .frame(width: 50, height: 50)
                                .onTapGesture {
                                    modalIsDisplayed = true
                                }
                            Spacer()
                            RoundImageView(url: Player.jessica.imageUrl)
                                .frame(width: 50, height: 50)
                                .onTapGesture {
                                    modalIsDisplayed = true
                                }
                            Spacer()
                        }
                        Image("pickleball_court")
                            .resizable()
                        HStack {
                            Spacer()
                            RoundImageView(url: Player.bryan.imageUrl)
                                .frame(width: 50, height: 50)
                                .onTapGesture {
                                    modalIsDisplayed = true
                                }
                            Spacer()
                            Spacer()
                            RoundImageView(url: Player.bob.imageUrl)
                                .frame(width: 50, height: 50)
                                .onTapGesture {
                                    modalIsDisplayed = true
                                }
                            Spacer()
                        }
                    }
                    .padding()
                }
                
//                VStack {
//                    Button("Tap to Report a Stat!") {
//                        modalIsDisplayed.toggle()
//                    }
//                    if let shot = savedShot {
//                        Text(shot.type.rawValue)
//                        Text(shot.result.rawValue)
//                        if let side = shot.side {
//                            Text(side.rawValue)
//                        }
//                    }
//                }
                if modalIsDisplayed {
                    ZStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.25))
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
        }//.edgesIgnoringSafeArea(.bottom)
    }
}

struct LiveMatchView_Previews: PreviewProvider {
    static var previews: some View {
        LiveMatchView()
    }
}
