//
//  BaseViewModel.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/27/21.
//

import Combine

class BaseViewModel: ObservableObject {
    var repository: Repository
    var errorHandler: ErrorHandler
    
    init(repository: Repository, errorHandler: ErrorHandler) {
        self.repository = repository
        self.errorHandler = errorHandler
    }
}
