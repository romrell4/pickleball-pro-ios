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
    case idle
    case loading(Value?)
    case failed(ProError, Value?)
    case success(Value)
    
    var data: Value? {
        switch self {
        case .idle: return nil
        case .loading(let value), .failed(_, let value): return value
        case .success(let value): return value
        }
    }
    
    mutating func startLoad() {
        self = .loading(data)
    }
    
    mutating func receivedFailure(_ error: ProError) {
        self = .failed(error, data)
    }
}

extension LoadingState {
    func dataOrEmpty<T>() -> [T] where Value == Array<T> {
        return data ?? []
    }
    
    mutating func add<T>(_ datum: T) where Value == Array<T> {
        self = .success(dataOrEmpty() + [datum])
    }
}
