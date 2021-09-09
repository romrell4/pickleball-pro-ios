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
    
    var errorDescription: String? {
        switch self {
        case .loadPlayersError: return "Unable to load players. Please try again later."
        case .createPlayerError: return "Unable to create player. Please try again later."
        case .deletePlayerError: return "Unable to delete player. Please try again later."
        case .updatePlayerError: return "Unable to update player. Please try again later."
        case .loadMatchesError: return "Unable to load matches. Please try again later."
        case .createMatchError: return "Unable to create match. Please try again later."
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

struct ErrorAlert: Identifiable {
    var id = UUID()
    var message: String
    var dismissAction: (() -> Void)?
}

class ErrorHandler: ObservableObject {
    @Published var currentAlert: ErrorAlert?

    func handle(error: ProError) {
        if let afError = error.afError {
            debugPrint(afError)
        }
        currentAlert = ErrorAlert(message: error.localizedDescription)
    }
}

struct HandleErrorsByShowingAlertViewModifier: ViewModifier {
    @StateObject var errorHandling = ErrorHandler()

    func body(content: Content) -> some View {
        content
            .environmentObject(errorHandling)
            // Applying the alert for error handling using a background element
            // is a workaround, if the alert would be applied directly,
            // other .alert modifiers inside of content would not work anymore
            .background(
                EmptyView()
                    .alert(item: $errorHandling.currentAlert) { currentAlert in
                        Alert(
                            title: Text("Error"),
                            message: Text(currentAlert.message),
                            dismissButton: .default(Text("OK")) {
                                currentAlert.dismissAction?()
                            }
                        )
                    }
            )
    }
}

extension View {
    func withErrorHandling() -> some View {
        modifier(HandleErrorsByShowingAlertViewModifier())
    }
}
