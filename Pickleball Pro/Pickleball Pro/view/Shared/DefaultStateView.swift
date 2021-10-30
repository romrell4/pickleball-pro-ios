//
//  DefaultStateView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 10/24/21.
//

import SwiftUI

struct DefaultStateView<SuccessType, Content: View>: View {
    let state: LoadingState<SuccessType>
    @ViewBuilder let content: (SuccessType) -> Content
    
    var body: some View {
        switch state {
        case .idle:
            VStack {}
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
    }
}

struct DefaultStateView_Previews: PreviewProvider {
    static let state: LoadingState<String> =
//        .idle
//        .failed(.loadPlayersError(afError: nil))
//        .failed(.loadPlayersError(afError: nil), "Test")
//        .loading(nil)
        .loading("Test")
//        .success("Test")
    static var previews: some View {
        NavigationView {
            DefaultStateView(state: state) { data in
                List(0..<10) {
                    Text("\(data) \($0)")
                }
            }
            .navigationTitle("Test")
        }
    }
}
