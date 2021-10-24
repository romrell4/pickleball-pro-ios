//
//  StatTracker.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/7/21.
//

import SwiftUI

struct StatTracker: View {
    private let player: Player
    private let onButtonTap: (Stat.Shot?) -> Void
    
    init(player: Player, shot: Stat.Shot? = nil, onButtonTap: @escaping (Stat.Shot?) -> Void) {
        self.player = player
        
        if let shot = shot {
            self.typeIndex = types.firstIndex(of: shot.type) ?? 0
            self.resultIndex = results.firstIndex(of: shot.result) ?? 0
            if let side = shot.side {
                self.sideIndex = sides.firstIndex(of: side) ?? 0
            }
        }
        self.onButtonTap = onButtonTap
    }
    
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
        VStack {
            player.image()
                .frame(width: 40, height: 40)
            
            Picker("Shot Type", selection: $typeIndex) {
                ForEach(types.indices, id: \.self) { index in
                    Text(types[index].rawValue.capitalized).tag(index)
                }
            }.pickerStyle(WheelPickerStyle())
            
            Picker("Result", selection: $resultIndex) {
                ForEach(results.indices, id: \.self) { index in
                    Text(results[index].rawValue.capitalized).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if !(selectedType == .serve) {
                Picker("Shot Side", selection: $sideIndex) {
                    ForEach(sides.indices, id: \.self) { index in
                        Text(sides[index].rawValue.capitalized).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            HStack {
                Button("Save") {
                    onButtonTap(Stat.Shot(type: selectedType, result: selectedResult, side: selectedSide))
                }
                .padding(.horizontal)
                Button("Cancel") {
                    onButtonTap(nil)
                }
                .foregroundColor(.red)
                .padding(.horizontal)
            }.padding(.top)
        }
        .frame(width: 200)
    }
}

struct StatTracker_Previews: PreviewProvider {
    static var previews: some View {
        StatTracker(player: Player.eric) { _ in
            print("Done")
        }
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}
