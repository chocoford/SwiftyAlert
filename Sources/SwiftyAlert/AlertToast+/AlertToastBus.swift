//
//  AlertToastBus.swift
//
//
//  Created by Chocoford on 2023/12/11.
//
//  Can not use AlertToast init function like `.init`

import SwiftUI

#if canImport(AlertToast)
import AlertToast
#else
public typealias AlertToast = FakeAlertToast
#endif

// 1. Create the key with a default value
private struct AlertToastActionKey: EnvironmentKey {
    static let defaultValue: AlertToastAction = AlertToastAction(
        isPresented: .constant(false),
        alertToast: .constant(AlertToast(displayMode: .hud, type: .error(.red))),
        duration: .constant(2),
        tapToDismiss: .constant(false),
        offsetY: .constant(0.0),
        onTap: .constant(nil),
        onCompletion: .constant(nil)
    )
}

public struct AlertToastAction: Sendable {
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
            queue.append(
                (alert, duration, tapToDismiss, offsetY, onTap, completion)
            )
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
                alert,
                duration: duration,
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
    @State private var alertToast: AlertToast = AlertToast(type: .error(.red))
    @State private var duration: Double = 2
    @State private var tapToDismiss: Bool = true
    @State private var offsetY: CGFloat = 0.0
    @State var onTap: (() -> Void)?
    @State var onCompletion: (() -> Void)?
    
    @State private var alertToastAction: AlertToastAction?
    
    func body(content: Content) -> some View {
        content
            .overlay {
                Color.clear // <-- otherwise view will be rerendered at the first alert.
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
            }
            .environment(
                \.alertToast,
                 alertToastAction ?? AlertToastActionKey.defaultValue
            )
            .onAppear {
                if alertToastAction == nil {
                    alertToastAction = AlertToastAction(
                        isPresented: $isPresented,
                        alertToast: $alertToast,
                        duration: $duration,
                        tapToDismiss: $tapToDismiss,
                        offsetY: $offsetY,
                        onTap: $onTap,
                        onCompletion: $onCompletion
                     )
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .alertToast)) { output in
                guard let payload = output.object as? AlertToastPayload else { return }
                alertToastAction?(
                    payload.alertToast,
                    duration: payload.duration,
                    tapToDismiss: payload.tapToDismiss,
                    offsetY: payload.offsetY,
                    onTap: payload.onTap,
                    completion: payload.onCompletion
                )
            }
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
            .onAppear {
                fatalError("AlertToast not detected.")
            }
#endif
    }
}


extension Notification.Name {
    internal static let alertToast = Notification.Name("AlertToast")
}

internal struct AlertToastPayload {
    var alertToast: AlertToast
    var duration: Double = 2
    var tapToDismiss: Bool = true
    var offsetY: CGFloat = 0.0
    var onTap: (() -> Void)?
    var onCompletion: (() -> Void)?
}

public func alertToast(
    alertToast: AlertToast,
    duration: Double = 2,
    tapToDismiss: Bool = true,
    offsetY: CGFloat = 0.0,
    onTap: (() -> Void)? = nil,
    onCompletion: (() -> Void)? = nil
) {
    NotificationCenter.default.post(
        name: .alertToast,
        object: AlertToastPayload(
            alertToast: alertToast,
            duration: duration,
            tapToDismiss: tapToDismiss,
            offsetY: offsetY,
            onTap: onTap,
            onCompletion: onCompletion
        )
    )
}
