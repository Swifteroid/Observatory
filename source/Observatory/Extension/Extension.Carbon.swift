import Foundation
import Carbon

/// Here we make EventHotKeyID instances comparable using `==` operator.
extension EventHotKeyID: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.signature == rhs.signature && lhs.id == rhs.id
    }
}
