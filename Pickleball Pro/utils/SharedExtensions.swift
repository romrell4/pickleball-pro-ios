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
    func image() -> some View {
        if let imageUrl = imageUrl, !imageUrl.isEmpty {
            return AnyView(RoundImageView(url: imageUrl))
        } else {
            return AnyView(InitialsImageView(firstName: _firstName ?? "", lastName: _lastName ?? ""))
        }
    }
}
