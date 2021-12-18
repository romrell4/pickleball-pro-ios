//
//  TestView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/12/21.
//

import SwiftUI

struct TestView: View {
    @State var someVar = false
    
    @State var color1: Color? = .red
    @State var color2: Color? = .blue
    @State var color3: Color? = .yellow
    @State var color4: Color? = .green
    
    var body: some View {
        VStack {
            HStack {
                if let color = color1 {
                    Circle().fill(color).onTapGesture { someVar = true }
                }
                if let color = color2 {
                    Circle().fill(color).onTapGesture { someVar = true }
                }
            }
            HStack {
                if let color = color3 {
                    Circle().fill(color).onTapGesture { someVar = true }
                }
                if let color = color4 {
                    Circle().fill(color).onTapGesture { someVar = true }
                }
            }
        }
    }
    
    @ViewBuilder func circle(_ color: Color?) -> some View {
        if let color = color {
            Circle().fill(color).onTapGesture {
                someVar = true
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View { TestView() }
}
