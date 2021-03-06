//
//  RoundImageView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct RoundImageView: View {
    let url: String
    
    var body: some View {
        WebImage(url: URL(string: url))
            .resizable()
            .indicator { _, _ in ProgressView() }
            .clipShape(Circle())
    }
}

struct RoundImageView_Previews: PreviewProvider {
    static var previews: some View {
        RoundImageView(url: "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png")
            .frame(width: 100, height: 100)
    }
}
