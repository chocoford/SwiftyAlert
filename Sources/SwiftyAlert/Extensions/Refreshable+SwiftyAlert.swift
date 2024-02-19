//
//  Refreshable+SwiftyAlert.swift
//
//
//  Created by Dove Zachary on 2024/2/19.
//

import SwiftUI

struct SwiftyAlertRefreshableModifier: ViewModifier {
    @Environment(\.alert) private var alert
    @Environment(\.alertToast) private var alertToast
    
    var errorHandler: SwiftyAlertType
    var action: () async throws -> Void
    
    init(_ errorHandler: SwiftyAlertType, action: @escaping () async throws -> Void) {
        self.errorHandler = errorHandler
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .refreshable {
                do {
                    try await action()
                } catch {
                    switch errorHandler {
                        case .alert:
                            alert(error: error)
                        case .alertToast:
                            alertToast(.init(error: error))
                        case .print:
                            print(error)
                    }
                }
            }
    }
}

extension View {
    @ViewBuilder
    public func refreshable(_ errorHandler: SwiftyAlertType, action: @escaping () async throws -> Void) -> some View {
        modifier(SwiftyAlertRefreshableModifier(errorHandler, action: action))
    }
}
