//
//  StatTracker.swift
//  Pickleball-Pro-Watch WatchKit Extension
//
//  Created by Eric Romrell on 12/12/21.
//
import SwiftUI

struct StatTrackerView: View {
    @Environment(\.presentationMode) var presentationMode
    let player: Player
    let onButtonTap: (LiveMatchShot) -> Void
    
    @State private var typeIndex = 0
    @State private var resultIndex = 0
    @State private var sideIndex = 0
    
    private let types = Stat.ShotType.allCases.sorted {
        $0.trackingOrder < $1.trackingOrder
    }
    private let results = Stat.Result.allCases
    private let sides = Stat.ShotSide.allCases
    
    private var selectedType: Stat.ShotType { types[typeIndex] }
    private var selectedResult: Stat.Result { results[resultIndex] }
    private var selectedSide: Stat.ShotSide? {
        selectedType == .serve ? nil : sides[sideIndex]
    }
    
    var body: some View {
        VStack(spacing: 1) {
            Picker("Shot Type", selection: $typeIndex) {
                ForEach(types.indices, id: \.self) { index in
                    Text(types[index].rawValue.capitalized).tag(index)
                }
            }
            .labelsHidden()
            .pickerStyle(WheelPickerStyle())
            
            Picker("Result", selection: $resultIndex) {
                ForEach(results.indices, id: \.self) { index in
                    Text(results[index].rawValue.capitalized).tag(index)
                }
            }
            .labelsHidden()
            
            Picker("Shot Side", selection: $sideIndex) {
                ForEach(sides.indices, id: \.self) { index in
                    Text(sides[index].rawValue.capitalized).tag(index)
                }
            }
            .labelsHidden()
            .opacity(selectedType == .serve ? 0 : 1)
            .disabled(selectedType == .serve)
            
            Button("Save") {
                onButtonTap(LiveMatchShot(playerId: player.id, type: selectedType, result: selectedResult, side: selectedSide))
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

#if DEBUG
struct StatTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        StatTrackerView(player: Player.eric) { _ in
            print("Saved")
        }
    }
}
#endif
