//
//  TestView.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/12/21.
//

import SwiftUI

struct TestView: View {
    @State private var match: TestMatch = TestMatch()

    var body: some View {
        VStack {
            Text("\(match.team1.score)").font(.title).padding().onTapGesture {
                match.track(result: nil, forTeam1: true)
            }
            Text("\(match.team2.score)").font(.title).padding().onTapGesture {
                match.track(result: nil, forTeam1: false)
            }
        }
    }
}

struct TestMatch {
    var team1: TestTeam = TestTeam()
    var team2: TestTeam = TestTeam()
    var results: [String?] = []
    
    mutating func track(result: String? = nil, forTeam1: Bool) {
        results.append(result)
        var team = forTeam1 ? team1 : team2
        team.givePoint()
    }
}

struct TestTeam {
    var score: Int = 0
    
    mutating func givePoint() {
        score += 1
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View { TestView() }
}
