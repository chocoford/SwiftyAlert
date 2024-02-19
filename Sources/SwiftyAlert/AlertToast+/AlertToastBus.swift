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

// This is because Xcode can not recognize #if canImport(AlertToast) when add package from url.
public struct FakeAlertToast {
    /// Determine how the alert will be display
    public enum DisplayMode: Equatable{
        
        ///Present at the center of the screen
        case alert
        
        ///Drop from the top of the screen
        case hud
        
        ///Banner from the bottom of the view
        case banner(_ transition: BannerAnimation)
    }
    
    /// Determine what the alert will display
    public enum AlertType: Equatable{
        
        ///Animated checkmark
        case complete(_ color: Color)
        
        ///Animated xmark
        case error(_ color: Color)
        
        ///System image from `SFSymbols`
        case systemImage(_ name: String, _ color: Color)
        
        ///Image from Assets
        case image(_ name: String, _ color: Color)
        
        ///Loading indicator (Circular)
        case loading
        
        ///Only text alert
        case regular
    }
    
    public enum BannerAnimation{
        case slide, pop
    }
    public enum AlertStyle: Equatable{
        
        case style(backgroundColor: Color? = nil,
                   titleColor: Color? = nil,
                   subTitleColor: Color? = nil,
                   titleFont: Font? = nil,
                   subTitleFont: Font? = nil)
        
        ///Get background color
        var backgroundColor: Color? {
            switch self{
            case .style(backgroundColor: let color, _, _, _, _):
                return color
            }
        }
        
        /// Get title color
        var titleColor: Color? {
            switch self{
            case .style(_,let color, _,_,_):
                return color
            }
        }
        
        /// Get subTitle color
        var subtitleColor: Color? {
            switch self{
            case .style(_,_, let color, _,_):
                return color
            }
        }
        
        /// Get title font
        var titleFont: Font? {
            switch self {
            case .style(_, _, _, titleFont: let font, _):
                return font
            }
        }
        
        /// Get subTitle font
        var subTitleFont: Font? {
            switch self {
            case .style(_, _, _, _, subTitleFont: let font):
                return font
            }
        }
    }
    
    public init() {}
    public init(
        displayMode: DisplayMode = .alert,
        type: AlertType,
        title: String? = nil,
        subTitle: String? = nil,
        style: AlertStyle? = nil
    ) {}
}

public typealias AlertToast = FakeAlertToast

#endif

// 1. Create the key with a default value
private struct AlertToastActionKey: EnvironmentKey {
#if canImport(AlertToast)
    static let defaultValue: AlertToastAction = AlertToastAction(
        isPresented: .constant(false),
        alertToast: .constant(AlertToast(displayMode: .hud, type: .error(.red))),
        duration: .constant(2),
        tapToDismiss: .constant(false),
        offsetY: .constant(0.0),
        onTap: .constant(nil),
        onCompletion: .constant(nil)
    )
#else
    static let defaultValue: AlertToastAction = AlertToastAction()
#endif
}

#if canImport(AlertToast)
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
        self.callAsFunction(.init(error: error))
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
#else
public struct AlertToastAction {
    public func callAsFunction(
        _ alert: AlertToast,
        duration: Double = 2,
        tapToDismiss: Bool = true,
        offsetY: CGFloat = 0,
        onTap: (() -> ())? = nil,
        completion: (() -> ())? = nil
    ) {}
    public func callAsFunction(_ error: Error) {}
}
#endif

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
