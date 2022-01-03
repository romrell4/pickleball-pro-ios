//
//  SegmentedPickerView.swift
//  Pickleball Pro Watch WatchKit Extension
//
//  Created by Eric Romrell on 1/3/22.
//

import SwiftUI

struct SegmentedPickerView: View {
    let items: [String]
    @Binding var selection: Int
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
            ForEach(0..<self.items.count, id: \.self) { index in
                Text(items[index])
                    .padding()
                    .frame(width: geometry.size.width / CGFloat(items.count))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(self.selection == index ? .systemBackground : .clear)
                    )
                    .onTapGesture {
                        selection = index
                    }
            }
        }
        }
    }
}

private extension Color {
    static let systemBackground = Color(red: 32/256, green: 32/256, blue: 32/256, opacity: 1)
}

struct SegmentedPickerView_Previews: PreviewProvider {
    private struct Test: View {
        @State var selection = 0
        
        var body: some View {
            SegmentedPickerView(items: ["Forehand", "Backhand"], selection: $selection)
        }
    }
    
    static var previews: some View {
        Test()
    }
}
