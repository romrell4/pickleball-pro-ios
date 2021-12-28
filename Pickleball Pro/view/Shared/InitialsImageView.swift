//
//  InitialsImageView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 10/20/21.
//

import SwiftUI


private let luminoscityThreshold: CGFloat = 140

struct InitialsImageView: View {
    let firstName: String
    let lastName: String
    
    var body: some View {
        GeometryReader { geometry in
            Circle()
                .fill(backgroundColor)
                .overlay(
                    Text(initials)
                        .font(.system(size: geometry.size.width * 0.45))
                        .foregroundColor(textColor)
                )
        }
    }
    
    private var textColor: Color {
        backgroundColor.luminoscity > luminoscityThreshold ? Color.black : Color.white
    }
    
    private var initials: String {
        [firstName, lastName].map { $0.capitalized.prefix(1) }.joined()
    }
    
    private var backgroundColor: Color {
        Color(hue: Double(abs("\(firstName)\(lastName)".persistantHash) % 256) / 256, saturation: 1.0, brightness: 1.0)
    }
}

extension String {
    var persistantHash: Int {
        return Int(self.utf8.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int32($1)
        })
    }
}

private extension Color {
    var luminoscity: CGFloat {
        guard let comps = UIColor(self).cgColor.components else { return 0 }
        let red = comps[0] * 0.299
        let green = comps[1] * 0.587
        let blue = comps[2] * 0.114
        return (red + green + blue) * 256
    }
}

struct InitialsImageView_Previews: PreviewProvider {
    static var previews: some View {
        InitialsImageView(firstName: "Jessica", lastName: "Romrell")
            .frame(width: 50, height: 50)
    }
}
