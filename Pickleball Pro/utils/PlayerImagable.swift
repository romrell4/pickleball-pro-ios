//
//  SharedExtensions.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 12/14/21.
//

import Foundation
import SwiftUI

protocol PlayerImagable {
    var imageUrl: String? { get }
    var _firstName: String? { get }
    var _lastName: String? { get }
}

extension PlayerImagable {
    @ViewBuilder func image() -> some View {
        if let imageUrl = imageUrl, !imageUrl.isEmpty {
            RoundImageView(url: imageUrl)
        } else {
            InitialsImageView(firstName: _firstName ?? "", lastName: _lastName ?? "")
        }
    }
}

extension LiveMatchPlayer {
    @ViewBuilder func imageWithServer(imageSize: CGFloat) -> some View {
        #if os(watchOS)
        let image = player.image()
            .frame(width: imageSize, height: imageSize)
        if let count = servingState.badgeNum {
            image.overlay(
                ZStack(alignment: .topTrailing) {
                    Color.clear
                    Text(String(count))
                        .foregroundColor(.black)
                        .frame(width: 20, height: 20)
                        .background(Color.yellow)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(.black))
                }
            )
        } else {
            image
        }
        #else
        HStack(spacing: 4) {
            player.image()
                .frame(width: imageSize, height: imageSize)
            servingState.image
        }
        #endif
    }
}

private extension LiveMatchPlayer.ServingState {
    var image: some View {
        VStack(spacing: 4) {
            let pickleballImage = Image("pickleball")
                .resizable()
                .frame(width: 20, height: 20)
            switch self {
            case .serving(let isFirstServer):
                pickleballImage
                if !isFirstServer {
                    pickleballImage
                }
            case .notServing: EmptyView()
            }
        }
    }
}
