//
//  StatTracker.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/7/21.
//

import SwiftUI

struct StatTracker: View {
    @State private var typeIndex = 0
    @State private var resultIndex = 0
    @State private var sideIndex = 0
    
    var body: some View {
        VStack {
            let types = Stat.ShotType.allCases.sorted {
                $0.trackingOrder < $1.trackingOrder
            }
            Picker("Shot Type", selection: $typeIndex) {
                ForEach(types.indices, id: \.self) { index in
                    Text(types[index].rawValue.capitalized)
                        .tag(index)
                }
            }
            
            Picker("Result", selection: $resultIndex) {
                Text("Winner").tag(0)
                Text("Error").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if !(types[typeIndex] == .serve) {
                Picker("Shot Side", selection: $sideIndex) {
                    Text("Forehand").tag(0)
                    Text("Backhand").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            HStack {
                Button("Save") {
                    print("Test")
                }
                Button("Cancel") {
                    
                }.foregroundColor(.red)
            }
        }
    }
}

struct StatTracker_Previews: PreviewProvider {
    static var previews: some View {
        StatTracker()
    }
}
