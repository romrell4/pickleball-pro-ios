//
//  DefaultStateView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 10/24/21.
//

import SwiftUI

struct DefaultStateView<SuccessType, Content: View>: View {
    let state: LoadingState<SuccessType>
    @State private var showLoginSheet: Bool = false
    @ViewBuilder let content: (SuccessType) -> Content
    
    var body: some View {
        Group {
            switch state {
            case .idle(let loggedIn):
                if loggedIn {
                    VStack {}
                } else {
                    VStack(spacing: 16) {
                        Text("👋")
                            .font(.system(size: 80))
                        Text("Please log in to start saving data")
                            .font(.title3)
                        Button("Login") {
                            showLoginSheet = true
                        }
                    }
                    .multilineTextAlignment(.center)
                }
            case .loading(let data):
                ZStack {
                    if let data = data {
                        content(data)
                        LoadingModalView()
                    } else {
                        ProgressView()
                    }
                }
            case .failed(let error, let data):
                ZStack {
                    if let data = data {
                        content(data)
                    }
                    ErrorModalView(error: error)
                }
            case .success(let data):
                content(data)
            }
        }.sheet(isPresented: $showLoginSheet) {
            LoginView()
        }
    }
}

struct DefaultStateView_Previews: PreviewProvider {
    struct PreviewState: Identifiable, Hashable {
        let id = UUID().uuidString
        let title: String
        let state: LoadingState<String>
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(title)
        }
        
        static func == (lhs: DefaultStateView_Previews.PreviewState, rhs: DefaultStateView_Previews.PreviewState) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    private static let states: [PreviewState] = [
        PreviewState(title: "Idle - Logged In", state: .idle(loggedIn: true)),
        PreviewState(title: "Idle - Logged Out", state: .idle(loggedIn: false)),
        PreviewState(title: "Loading - No Prior data", state: .loading(nil)),
        PreviewState(title: "Loading - Prior Data", state: .loading("Test")),
        PreviewState(title: "Failed - No Prior Data", state: .failed(.loadPlayersError(afError: nil), nil)),
        PreviewState(title: "Failed - Prior Data", state: .failed(.loadPlayersError(afError: nil), "Test")),
        PreviewState(title: "Success", state: .success("Test"))
    ]
    
    struct Preview: View {
        @State private var selectedState = states[3]
        
        var body: some View {
            NavigationView {
                DefaultStateView(state: selectedState.state) { data in
                    List(0..<10) {
                        Text("\(data) \($0)")
                    }
                }
                .navigationBarTitle("Test", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Picker("Select a state fixture", selection: $selectedState) {
                            ForEach(states, id: \.self) {
                                Text($0.title)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
            }
        }
    }
                            
    static var previews: some View {
        Preview()
    }
}
