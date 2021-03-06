//
//  ModalView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 9/9/21.
//

import SwiftUI

struct ModalView<Content: View>: View {
    let onDismiss: () -> Void
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.45))
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onDismiss()
                }
            content()
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
        }
    }
}

struct LoadingModalView: View {
    var body: some View {
        ModalView(onDismiss: {}) {
            ProgressView()
        }
    }
}

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ModalView(onDismiss: { print("dismiss") }) {
                Text("Hello world this is a long test that will helpfull wrap before")
            }.navigationBarTitle("Test", displayMode: .inline)
        }
    }
}
