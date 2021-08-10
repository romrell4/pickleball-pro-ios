//
//  ViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/8/21.
//

import Combine

class ViewModel: ObservableObject {
    @Published var matches = [Match]()
    
    func loadMatches() {
        matches = [
            Match.doubles,
            Match.singles,
        ]
//        URLSession.shared.dataTaskPublisher(for: url)
//            .map { $0.data }
//            .decode(type: [Book].self, decoder: JSONDecoder())
//            .replaceError(with: [])
//            .eraseToAnyPublisher()
//            .receive(on: DispatchQueue.main)
//            .assign(to: &$books)
    }
}
