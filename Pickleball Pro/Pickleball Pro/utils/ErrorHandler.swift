//
//  ErrorHandler.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 8/27/21.
//

import SwiftUI
import Alamofire

enum ProError: LocalizedError {
    case loadPlayersError(afError: AFError?)
    case createPlayerError(afError: AFError?)
    case deletePlayerError(afError: AFError?)
    case updatePlayerError(afError: AFError?)
    
    case loadMatchesError(afError: AFError?)
    case createMatchError(afError: AFError?)
    
    case genericError(afError: AFError?)
    
    var errorDescription: String {
        switch self {
        case .loadPlayersError: return "Unable to load players. Please try again later."
        case .createPlayerError: return "Unable to save player. Please try again later."
        case .deletePlayerError: return "Unable to delete player. Please try again later."
        case .updatePlayerError: return "Unable to update player. Please try again later."
        case .loadMatchesError: return "Unable to load matches. Please try again later."
        case .createMatchError: return "Unable to save match. Please try again later."
        case .genericError: return "Uh oh. Something went wrong. Please try again later."
        }
    }
    
    var afError: AFError? {
        switch self {
        case .loadPlayersError(let afError),
             .createPlayerError(let afError),
             .deletePlayerError(let afError),
             .updatePlayerError(let afError),
             .loadMatchesError(let afError),
             .createMatchError(let afError),
             .genericError(let afError):
            return afError
        }
    }
}
