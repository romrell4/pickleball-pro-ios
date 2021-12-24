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
