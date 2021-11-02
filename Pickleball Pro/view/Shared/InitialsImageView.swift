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
        Color(hue: Double(abs("\(firstName)\(lastName)".hash) % 256) / 256, saturation: 1.0, brightness: 1.0)
    }
}

struct InitialsImageView_Previews: PreviewProvider {
    static var previews: some View {
        InitialsImageView(firstName: "Jessica", lastName: "Romrell")
            .frame(width: 50, height: 50)
    }
}
