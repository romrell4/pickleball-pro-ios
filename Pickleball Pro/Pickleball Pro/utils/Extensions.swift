//
//  Extensions.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import Foundation
import SwiftUI

extension Binding {
    static func proxy(_ source: Binding<Value>) -> Binding<Value> {
        self.init(
            get: { source.wrappedValue },
            set: { source.wrappedValue = $0 }
        )
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
