//
//  BaseViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/27/21.
//

import Combine

class BaseViewModel<ViewState>: ObservableObject, LoginListener {
    @Published var state: LoadingState<ViewState>
    var repository: Repository
    let loginManager: LoginManager
    
    init(repository: Repository, loginManager: LoginManager) {
        self.repository = repository
        self.loginManager = loginManager
        state = .idle(loggedIn: loginManager.isLoggedIn)
        loginManager.add(listener: self)
    }
    
    /// This function is meant to be overrideen. Each view model should impement their own logic to deal with a user logging in or out
    func loginChanged(isLoggedIn: Bool) {}
}

enum LoadingState<Value> {
    case idle(loggedIn: Bool)
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
    
    var isLoading: Bool {
        switch self {
        case .loading: return true
        default: return false
        }
    }
    
    var isLoggedOut: Bool {
        switch self {
        case .idle(let loggedIn): return !loggedIn
        default: return false
        }
    }
    
    mutating func startLoad() {
        self = .loading(data)
    }
    
    mutating func receivedFailure(_ error: ProError) {
        self = .failed(error, data)
    }
    
    mutating func loggedOut() {
        self = .idle(loggedIn: false)
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
