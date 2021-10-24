//
//  ErrorView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 10/24/21.
//

import SwiftUI

struct ErrorModalView: View {
    let error: ProError
    @State private var isShowing = true
    
    var body: some View {
        if isShowing {
            ModalView(onDismiss: dismiss) {
                VStack(spacing: 10) {
                    Text("😔").font(.system(size: 50))
                    Text(error.errorDescription)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    Button("OK") {
                        dismiss()
                    }
                }
            }
        } else {
            VStack {}
        }
    }
    
    private func dismiss() {
        isShowing = false
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ErrorModalView(error: .loadPlayersError(afError: nil))
                .navigationTitle("Test")
        }
    }
}
