
import SwiftUI

public enum SwiftyAlertType {
    case alert
    case alertToast
    case print
}

public struct SwiftyAlertTypes: OptionSet {
    public var rawValue: Int
    
    public static let alert = SwiftyAlertTypes(rawValue:  1 << 0)
    public static let alertToast = SwiftyAlertTypes(rawValue:  1 << 1)
    public static let all: SwiftyAlertTypes = [.alert, .alertToast]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}


extension View {
    @ViewBuilder
    public func swifyAlert(_ types: SwiftyAlertTypes = .all) -> some View {
        self
            .injectAlertBus(enabled: types.contains(.alert))
            .injectAlertToastBus(enabled: types.contains(.alertToast))
    }
}
