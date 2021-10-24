//
//  BaseViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/27/21.
//

import Combine

class BaseViewModel: ObservableObject {
    var repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    func clear() {}
}

enum LoadingState<Value> {
    case loading
    case failed(ProError)
    case success(Value)
}
