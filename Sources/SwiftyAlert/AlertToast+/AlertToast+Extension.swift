//
//  File.swift
//  
//
//  Created by Chocoford on 2023/12/27.
//

#if canImport(AlertToast)
import Foundation
import AlertToast

extension AlertToast {
    public init(
        error: Error,
        displayMode: AlertToast.DisplayMode = .hud,
        type: AlertToast.AlertType = .error(.red)
    ) {
        if let error = error as? LocalizedError {
            self = .init(
                displayMode: displayMode, type: type,
                title: error.errorDescription, subTitle: error.failureReason
            )

        } else {
            self = .init(displayMode: displayMode, type: type, title: error.localizedDescription)
        }
    }
}
#endif
