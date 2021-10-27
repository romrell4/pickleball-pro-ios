//
//  Extensions.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import Foundation
import SwiftUI

extension Alert {
    func toProAlert() -> ProAlert {
        return ProAlert(alert: self)
    }
}

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

extension Color {    
    var luminoscity: CGFloat {
        guard let comps = UIColor(self).cgColor.components else { return 0 }
        let red = comps[0] * 0.299
        let green = comps[1] * 0.587
        let blue = comps[2] * 0.114
        return (red + green + blue) * 256
    }
}

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

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        tapGesture.name = "MyTapGesture"
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
