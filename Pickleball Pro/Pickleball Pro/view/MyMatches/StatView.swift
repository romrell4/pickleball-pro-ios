//
//  StatView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/4/21.
//

import SwiftUI

private let BAR_HORIZONTAL_PADDING: CGFloat = 32

struct ParentStatView: View {
    let statGrouping: Stat.Grouping
    
    @State private var childrenVisible = false
    
    private func toggleChildren() {
        withAnimation(.easeInOut(duration: 1)) {
            childrenVisible.toggle()
        }
    }
    
    var body: some View {
        VStack {
            if statGrouping.hasChildren {
                StatView(statGrouping: statGrouping, topLevel: true) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .rotationEffect(.degrees(childrenVisible ? 90 : 0))
                }
                .frame(height: 25)
                .onTapGesture {
                    toggleChildren()
                }
            } else {
                StatView(statGrouping: statGrouping, topLevel: true)
                    .frame(height: 25)
            }
            if childrenVisible {
                VStack {
                    StatView(statGrouping: statGrouping.forehandGrouping, topLevel: false)
                        .frame(height: 20)
                    StatView(statGrouping: statGrouping.backhandGrouping, topLevel: false)
                        .frame(height: 20)
                }
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.2))
            }
        }
    }
}

extension StatView where Content == EmptyView {
    init(statGrouping: Stat.Grouping, topLevel: Bool) {
        self.init(statGrouping: statGrouping, topLevel: topLevel, chevronImageBuilder: { EmptyView() })
    }
}

struct StatView<Content: View>: View {
    let statGrouping: Stat.Grouping
    let topLevel: Bool
    var chevronImage: Content
    
    var font: Font {
        topLevel ? .body : .caption
    }
    
    init(statGrouping: Stat.Grouping, topLevel: Bool, chevronImageBuilder: () -> Content) {
        self.statGrouping = statGrouping
        self.topLevel = topLevel
        self.chevronImage = chevronImageBuilder()
    }
    
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
                }
            }
            
            HStack(spacing: 0) {
                Text("\(statGrouping.team1Amount)").font(font)
                Spacer()
                Text(statGrouping.label).font(font)
                chevronImage.padding(.leading, 4)
                Spacer()
                Text("\(statGrouping.team2Amount)").font(font)
            }
            .padding(.horizontal, 10)
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
        ParentStatView(
            statGrouping: Stat.Grouping(
                label: "Dropshots",
                team1Stats: Array(repeating: Stat.stat(side: .forehand), count: 1),
                team2Stats: Array(repeating: Stat.stat(side: .backhand), count: 9),
                hasChildren: true
            )
        )
        .previewLayout(.sizeThatFits)
    }
}
