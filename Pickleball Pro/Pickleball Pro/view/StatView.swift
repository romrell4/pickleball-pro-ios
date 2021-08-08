//
//  StatView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/4/21.
//

import SwiftUI

private let BAR_HORIZONTAL_PADDING: CGFloat = 32

struct StatView: View {
    let statGrouping: Stat.Grouping
    
    private func getWidths(fullWidth: CGFloat) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        let (team1Amount, team2Amount) = (CGFloat(statGrouping.team1Amount), CGFloat(statGrouping.team2Amount))
        let maxWidth = fullWidth / 2 - BAR_HORIZONTAL_PADDING
        let maxAmount = max(team1Amount, team2Amount)
        
        var (team1Width, team2Width) = (CGFloat(0), CGFloat(0))
        if maxAmount > 0 {
            team1Width = team1Amount / maxAmount * maxWidth
            team2Width = team2Amount / maxAmount * maxWidth
        }
        return (BAR_HORIZONTAL_PADDING + maxWidth - team1Width, team1Width, team2Width, BAR_HORIZONTAL_PADDING + maxWidth - team2Width)
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    let (leadingSpace, team1Width, team2Width, trailingSpace) = getWidths(fullWidth: geometry.size.width)
                    HStack(spacing: 0) {
                        Spacer()
                            .frame(width: leadingSpace)
                        HStack(spacing: 0) {
                            RoundedCornersShape(corners: [.topLeft, .bottomLeft])
                                .fill(Color.red.opacity(0.25))
                                .frame(width: team1Width)
                            RoundedCornersShape(corners: [.topRight, .bottomRight])
                                .fill(Color.blue.opacity(0.25))
                                .frame(width: team2Width)
                        }
                        Spacer()
                            .frame(width: trailingSpace)
                    }
                    Spacer()
                }
            }
            
            HStack(spacing: 0) {
                Text("\(statGrouping.team1Amount)").font(.caption)
                Spacer()
                Text(statGrouping.label).font(.caption)
                Spacer()
                Text("\(statGrouping.team2Amount)").font(.caption)
            }
        }
    }
}

struct RoundedCornersShape: Shape {
    let corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let radius = rect.size.height / 2
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct StatView_Previews: PreviewProvider {
    static var previews: some View {
        StatView(
            statGrouping: Stat.Grouping(
                label: "Aces",
                team1Amount: 1,
                team2Amount: 9
            )
        )
        .frame(height: 35)
        .padding()
    }
}
