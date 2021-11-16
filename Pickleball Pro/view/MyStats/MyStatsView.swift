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
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                        Text("Overall Record")
                        RecordView(state: state)
                        
                        // TODO: Add other charts and stuff?
//                        if let recordOverTime = state.recordOverTime {
//                            BarChartView(data: ChartData(values: recordOverTime), title: "Record over time", form: ChartForm.large, dropShadow: true, cornerImage: nil, valueSpecifier: "%.2f")
//                                .padding()
//                        } else {
//
//                        }
                        
                        
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
