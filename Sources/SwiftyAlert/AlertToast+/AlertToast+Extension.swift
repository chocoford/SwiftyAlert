//
//  File.swift
//  
//
//  Created by Chocoford on 2023/12/27.
//

import Foundation
import SwiftUI
#if canImport(AlertToast)
import AlertToast
#endif

extension AlertToast {
    public init(
        error: Error,
        displayMode: DisplayMode = DisplayMode.hud,
        type: AlertType = AlertType.error(.red)
    ) {
        if let error = error as? LocalizedError {
            
            let errorDescription = if error.errorDescription?.isEmpty != false {
                error.localizedDescription
            } else {
                error.errorDescription
            }
            
            self = .init(
                displayMode: displayMode,
                type: type,
                title: errorDescription,
                subTitle: error.failureReason
            )

        } else {
            self = .init(
                displayMode: displayMode,
                type: type,
                title: "Error",
                subTitle: error.localizedDescription
            )
        }
    }
}
