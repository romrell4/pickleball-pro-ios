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
        case .loading:
            ProgressView()
        case .failed(let error):
            ErrorModalView(error: error)
        case .success(let data):
            content(data)
        }
    }
}

struct DefaultStateView_Previews: PreviewProvider {
    static let state: LoadingState<String> = .failed(.loadPlayersError(afError: nil))
    static var previews: some View {
        NavigationView {
            DefaultStateView(state: state) { data in
                Text(data)
            }
            .navigationTitle("Test")
        }
    }
}
