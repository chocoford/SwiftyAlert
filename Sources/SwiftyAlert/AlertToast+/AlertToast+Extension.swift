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
//#endif

extension AlertToast {
    public init(
        error: Error,
        displayMode: AlertToast.DisplayMode = AlertToast.DisplayMode.hud,
        type: AlertToast.AlertType = AlertToast.AlertType.error(.red)
    ) {
        if let error = error as? LocalizedError {
            self = .init(
                displayMode: displayMode,
                type: type,
                title: error.errorDescription,
                subTitle: error.failureReason
            )

        } else {
            self = .init(
                displayMode: displayMode,
                type: type,
                title: error.localizedDescription
            )
        }
    }
}
#else
extension FakeAlertToast {
    public init(
        error: Error,
        displayMode: FakeAlertToast.DisplayMode = FakeAlertToast.DisplayMode.hud,
        type: FakeAlertToast.AlertType = FakeAlertToast.AlertType.error(.red)
    ) {
        if let error = error as? LocalizedError {
            self = .init(
                displayMode: displayMode,
                type: type,
                title: error.errorDescription,
                subTitle: error.failureReason
            )

        } else {
            self = .init(
                displayMode: displayMode,
                type: type,
                title: error.localizedDescription
            )
        }
    }
}
#endif
