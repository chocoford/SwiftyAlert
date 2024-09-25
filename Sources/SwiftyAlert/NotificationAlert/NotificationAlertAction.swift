//
//  File.swift
//  SwiftyAlert
//
//  Created by Dove Zachary on 2024/8/31.
//

import Foundation
import SwiftUI

//extension Notification.Name {
//    static let swiftyNotification = Notification.Name("SwiftyNotification")
//}
//
//private struct NotificationActionKey: EnvironmentKey {
//    static let defaultValue: NotificationAction = .init(
//        title: .constant("Alert"),
//        isPresented: .constant(false),
//        actions: .constant(AnyView(EmptyView())),
//        message: .constant(AnyView(EmptyView()))
//    )
//}
//
//public struct NotificationAction {
//    @Binding var title: LocalizedStringKey
//    @Binding var isPresented: Bool
//    @Binding var actions: AnyView
//    @Binding var message: AnyView
//    
//    public func callAsFunction(
//        title: LocalizedStringKey,
//        @ViewBuilder actions: @escaping () -> some View = { EmptyView() },
//        @ViewBuilder message: @escaping () -> some View
//    ) {
//        if self.isPresented {
//            self.isPresented.toggle()
//            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(500))) {
//                self.toggleAlert(title: title, actions: actions, message: message)
//            }
//        } else {
//            self.toggleAlert(title: title, actions: actions, message: message)
//        }
//    }
//    
//    public func callAsFunction(
//        title: LocalizedStringKey = "Error",
//        error: Error
//    ) {
//        if let error = error as? LocalizedError {
//            self.callAsFunction(title: title) {
//                Text(error.errorDescription ?? error.localizedDescription)
//            }
//        } else {
//            self.callAsFunction(title: title) {
//                Text(error.localizedDescription)
//            }
//        }
//    }
//    
//    private func toggleAlert(
//        title: LocalizedStringKey,
//        @ViewBuilder actions: () -> some View,
//        @ViewBuilder message: () -> some View
//    ) {
//        self.isPresented.toggle()
//        
//        self.title = title
//        self.actions = AnyView(actions())
//        self.message = AnyView(message())
//    }
//}
//
//// 2. Extend the environment with our property
//extension EnvironmentValues {
//    public internal(set) var notify: NotificationAction {
//        get { self[NotificationActionKey.self] }
//        set { self[NotificationActionKey.self] = newValue }
//    }
//}
//
//
//struct NotificationViewModifier: ViewModifier {
//    @State private var title: LocalizedStringKey = ""
//    @State private var isPresented: Bool = false
//    @State private var actions: AnyView = AnyView(EmptyView())
//    @State private var message: AnyView = AnyView(EmptyView())
//
//    @State private var alertAction: AlertAction?
//
//    func body(content: Content) -> some View {
//        content
//            .environment(
//                \.alert,
//                 alertAction ?? AlertActionKey.defaultValue
//            )
//            .onReceive(NotificationCenter.default.publisher(for: .swiftyNotification)) { output in
//                
//            }
//            .onAppear {
//                if alertAction == nil {
//                    self.alertAction = AlertAction(
//                       title: $title,
//                       isPresented: $isPresented,
//                       actions: $actions,
//                       message: $message
//                    )
//                }
//            }
//    }
//}
//
//
//extension View {
//    @ViewBuilder
//    internal func injectNotificationBus(enabled flag: Bool = true) -> some View {
//        if flag {
//            modifier(NotificationViewModifier())
//        } else {
//            self
//        }
//    }
//}
