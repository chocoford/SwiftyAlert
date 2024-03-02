//
//  AlertToastBus.swift
//
//
//  Created by Chocoford on 2023/12/11.
//

import SwiftUI

#if canImport(AlertToast)
import AlertToast
#else
public typealias AlertToast = FakeAlertToast
#endif

// 1. Create the key with a default value
private struct AlertToastActionKey: EnvironmentKey {
//#if canImport(AlertToast)
    static let defaultValue: AlertToastAction = AlertToastAction(
        isPresented: .constant(false),
        alertToast: .constant(AlertToast(displayMode: .hud, type: .error(.red))),
        duration: .constant(2),
        tapToDismiss: .constant(false),
        offsetY: .constant(0.0),
        onTap: .constant(nil),
        onCompletion: .constant(nil)
    )
//#else
//    static let defaultValue: AlertToastAction = AlertToastAction()
//#endif
}

//#if canImport(AlertToast)
public struct AlertToastAction {
    @Binding var isPresented: Bool
    @Binding var alertToast: AlertToast
    @Binding var duration: Double
    @Binding var tapToDismiss: Bool
    @Binding var offsetY: CGFloat
    @Binding var onTap: (() -> Void)?
    @Binding var onCompletion: (() -> Void)?
    
    @State private var queue: [(AlertToast, Double, Bool, CGFloat, (() -> ())?, (() -> ())?)] = []
    
    public func callAsFunction(
        _ alert: AlertToast,
        duration: Double = 2,
        tapToDismiss: Bool = true,
        offsetY: CGFloat = 0,
        onTap: (() -> ())? = nil,
        completion: (() -> ())? = nil
    ) {
        if self.isPresented {
            queue.append((alert, duration, tapToDismiss, offsetY, onTap, completion))
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                if queue.isEmpty { timer.invalidate(); return }
                let parms = queue.removeFirst()
                self.toggleAlertToast(
                    parms.0,
                    duration: parms.1,
                    tapToDismiss: parms.2,
                    offsetY: parms.3,
                    onTap: parms.4,
                    completion: parms.5
                )
            }
        } else {
            self.toggleAlertToast(
                alert, duration: duration,
                tapToDismiss: tapToDismiss,
                offsetY: offsetY,
                onTap: onTap,
                completion: completion
            )
        }
    }
    
    public func callAsFunction(_ error: Error) {
        self.callAsFunction(AlertToast(error: error))
    }
    
    private func toggleAlertToast(
        _ alert: AlertToast,
        duration: Double = 2,
        tapToDismiss: Bool = true,
        offsetY: CGFloat = 0,
        onTap: (() -> ())? = nil,
        completion: (() -> ())? = nil
    ) {
        withAnimation {
            self.isPresented = true
        }
        self.alertToast = alert
        self.duration = duration
        self.tapToDismiss = tapToDismiss
        self.offsetY = offsetY
        self.onTap = onTap
        self.onCompletion = completion
    }
}
//#else
//public struct AlertToastAction {
//    public func callAsFunction(
//        _ alert: AlertToast,
//        duration: Double = 2,
//        tapToDismiss: Bool = true,
//        offsetY: CGFloat = 0,
//        onTap: (() -> ())? = nil,
//        completion: (() -> ())? = nil
//    ) {}
//    public func callAsFunction(_ error: Error) {}
//}
//#endif

// 2. Extend the environment with our property
extension EnvironmentValues {
    public internal(set) var alertToast: AlertToastAction {
        get { self[AlertToastActionKey.self] }
        set { self[AlertToastActionKey.self] = newValue }
    }
}

#if canImport(AlertToast)
struct AlertToastViewModifier: ViewModifier {
    @State private var isPresented: Bool = false
    @State private var alertToast: AlertToast = .init(type: .error(.red))
    @State private var duration: Double = 2
    @State private var tapToDismiss: Bool = true
    @State private var offsetY: CGFloat = 0.0
    @State var onTap: (() -> Void)?
    @State var onCompletion: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .toast(
                isPresenting: $isPresented,
                duration: duration,
                tapToDismiss: tapToDismiss,
                offsetY: offsetY
            ) {
                self.alertToast
            } onTap: {
                self.onTap?()
            } completion: {
                self.onCompletion?()
            }
            .environment(
                \.alertToast,
                 AlertToastAction(
                    isPresented: $isPresented,
                    alertToast: $alertToast,
                    duration: $duration,
                    tapToDismiss: $tapToDismiss,
                    offsetY: $offsetY,
                    onTap: $onTap,
                    onCompletion: $onCompletion
                 )
            )
    }
}
#endif

// 3. Optional convenience view modifier
extension View {
    @ViewBuilder
    internal func injectAlertToastBus(enabled flag: Bool = true) -> some View {
#if canImport(AlertToast)
        if flag {
            modifier(AlertToastViewModifier())
        } else {
            self
        }
#else
        self
#endif
    }
}
