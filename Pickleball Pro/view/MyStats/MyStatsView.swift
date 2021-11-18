//
//  MyStatsView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import SwiftUI

struct MyStatsView: View {
    @EnvironmentObject var viewModel: StatsViewModel
    
    var body: some View {
        NavigationView {
            DefaultStateView(state: viewModel.state) { state in
                ScrollView {
                    VStack {
                        Picker("Filter", selection: $viewModel.filter) {
                            ForEach(StatsFilter.allCases, id: \.self) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                        Text("Overall Record")
                        RecordView(state: state)
                        
                        // TODO: Add other charts and stuff?
                        // X-Axis: Shot Type
                        // Y-Axis: Amount
                        // Red Bar: Errors
                        // Blue Bar: Winners
                        // Look into zooming into x-axis shot types?
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitle("Stats", displayMode: .inline)
        }
        .onAppear {
            viewModel.load()
        }
    }
}

private struct RecordView: View {
    let state: StatsViewState
    
    var body: some View {
        GroupBox {
            HStack(alignment: .bottom) {
                VStack(spacing: 10) {
                    Text("Wins")
                        .font(.caption2)
                    Text("\(state.wins)")
                        .font(.title)
                }.padding(.horizontal)
                Text("-").font(.title)
                VStack(spacing: 10) {
                    Text("Losses")
                        .font(.caption2)
                    Text("\(state.losses)")
                        .font(.title)
                }.padding(.horizontal)
                Text("-").font(.title)
                VStack(spacing: 10) {
                    Text("Ties")
                        .font(.caption2)
                    Text("\(state.ties)")
                        .font(.title)
                }.padding(.horizontal)
            }
        }
    }
}

#if DEBUG
struct MyStatsView_Previews: PreviewProvider {
    static var previews: some View {
        MyStatsView()
            .environmentObject(StatsViewModel(repository: TestRepository(), loginManager: TestLoginManager()))
    }
}
#endif
