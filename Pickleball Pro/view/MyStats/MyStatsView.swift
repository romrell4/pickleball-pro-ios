//
//  MyStatsView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import SwiftUI
import Charts

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
                            .font(.title2)
                        RecordView(state: state)
                        
                        Text("Winners vs Errors")
                            .font(.title2)
                            .padding(.top)
                        GroupBox {
                            HStack(spacing: 0) {
                                VStack(spacing: 0) {
                                    Text("Forehand")
                                    WinnerErrorPieChart(data: state.forehandShotResultData)
                                        .frame(height: 200)
                                }
                                VStack(spacing: 0) {
                                    Text("Backhand")
                                    WinnerErrorPieChart(data: state.backhandShotResultData)
                                        .frame(height: 200)
                                }
                            }
                        }.padding(.horizontal)
                        
                        Text("Shots by Type")
                            .font(.title2)
                            .padding(.top)
                        GroupBox {
                            ShotTypeBarChart(data: state.shotTypeData)
                                .frame(height: 300)
                        }.padding(.horizontal)
                    }
                }
            }
            .navigationBarTitle("Stats", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("Select a date filter", selection: $viewModel.dateFilter) {
                        ForEach(DateFilter.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
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
