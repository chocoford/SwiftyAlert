//
//  Alert.swift
//
//
//  Created by Chocoford on 2024/2/7.
//

import Foundation
import SwiftUI

// 1. Create the key with a default value
private struct AlertActionKey: EnvironmentKey {
    static let defaultValue: AlertAction = .init(
        title: .constant("Alert"),
        isPresented: .constant(false),
        actions: .constant(AnyView(EmptyView())),
        message: .constant(AnyView(EmptyView()))
    )
}

public struct AlertAction {
    @Binding var title: LocalizedStringKey
    @Binding var isPresented: Bool
    @Binding var actions: AnyView
    @Binding var message: AnyView
    
    public func callAsFunction(
        title: LocalizedStringKey,
        @ViewBuilder actions: @escaping () -> some View = { EmptyView() },
        @ViewBuilder message: @escaping () -> some View
    ) {
        if self.isPresented {
            self.isPresented.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(500))) {
                self.toggleAlert(title: title, actions: actions, message: message)
            }
        } else {
            self.toggleAlert(title: title, actions: actions, message: message)
        }
    }
    
    public func callAsFunction(
        title: LocalizedStringKey = "Error",
        error: Error
    ) {
        if let error = error as? LocalizedError {
            self.callAsFunction(title: title) {
                Text(error.errorDescription ?? error.localizedDescription)
            }
        } else {
            self.callAsFunction(title: title) {
                Text(error.localizedDescription)
            }
        }
    }
    
    private func toggleAlert(
        title: LocalizedStringKey,
        @ViewBuilder actions: () -> some View,
        @ViewBuilder message: () -> some View
    ) {
        self.isPresented.toggle()
        
        self.title = title
        self.actions = AnyView(actions())
        self.message = AnyView(message())
    }
}

// 2. Extend the environment with our property
extension EnvironmentValues {
    public internal(set) var alert: AlertAction {
        get { self[AlertActionKey.self] }
        set { self[AlertActionKey.self] = newValue }
    }
}

extension Notification.Name {
    public static let alert = Notification.Name("Alert")
}

public struct AlertPayload {
    var title: LocalizedStringKey = ""
    var isPresented: Bool = false
    var actions: AnyView
    var message: AnyView
    
    init<Actions: View, Message: View>(
        title: LocalizedStringKey,
        isPresented: Bool,
        actions: () -> Actions,
        message: () -> Message
    ) {
        self.title = title
        self.isPresented = isPresented
        self.actions = AnyView(actions())
        self.message = AnyView(message())
    }
}


struct AlertViewModifier: ViewModifier {
    @State private var title: LocalizedStringKey = ""
    @State private var isPresented: Bool = false
    @State private var actions: AnyView = AnyView(EmptyView())
    @State private var message: AnyView = AnyView(EmptyView())
    
    @State private var alertAction: AlertAction?
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isPresented) {
                actions
            } message: {
                message
            }
            .environment(
                \.alert,
                 alertAction ?? AlertActionKey.defaultValue
            )
            .onReceive(NotificationCenter.default.publisher(for: .alert)) { output in
                guard let payload = output.object as? AlertPayload else { return }
                self.alertAction?(title: title) {
                    actions
                } message: {
                    message
                }
            }
            .onAppear {
                if alertAction == nil {
                    self.alertAction = AlertAction(
                       title: $title,
                       isPresented: $isPresented,
                       actions: $actions,
                       message: $message
                    )
                }
            }
    }
}

// 3. Optional convenience view modifier
extension View {
    @ViewBuilder
    internal func injectAlertBus(enabled flag: Bool = true) -> some View {
        if flag {
            modifier(AlertViewModifier())
        } else {
            self
        }
    }
}
