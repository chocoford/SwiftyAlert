//
//  View+TryTask.swift
//
//
//  Created by Chocoford on 2024/2/7.
//

import Foundation
import SwiftUI

public enum TryTaskErrorHandler {
    case alert
#if canImport(AlertTast)
    case alertToast
#endif
    case print
}

struct TryTaskViewModifier: ViewModifier {
    @Environment(\.alert) var alert
    #if canImport(AlertTast)
    @Environment(\.alertToast) var alertToast
    #endif
    var priority: TaskPriority
    var errorHandler: TryTaskErrorHandler
    var action: () async throws -> Void
    
    init(
        priority: TaskPriority = .userInitiated,
        errorHandler: TryTaskErrorHandler = .print,
        _ action: @escaping () async throws -> Void
    ) {
        self.priority = priority
        self.errorHandler = errorHandler
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .task(priority: priority) {
                do {
                    try await action()
                } catch {
                    if errorHandler != .print {
                        print(error)
                    }
                    switch errorHandler {
                        case .alert:
                            alert(error: error)
#if canImport(AlertTast)
                        case .alertToast:
                            alertToast(.init(error: error))
#endif
                        case .print:
                            print(error)
                    }
                }
            }
    }
}

extension View {
    @ViewBuilder
    public func tryTask(
        priority: TaskPriority = .userInitiated,
        errorHandler: TryTaskErrorHandler = .print,
        _ action: @escaping () async throws -> Void
    ) -> some View {
        modifier(TryTaskViewModifier(priority: priority, errorHandler: errorHandler, action))
    }
}

