import Foundation
import Carbon

/// Here we make EventHotKeyID instances comparable using `==` operator.
extension EventHotKeyID: Equatable
{
    public static func ==(lhs: EventHotKeyID, rhs: EventHotKeyID) -> Bool {
        return lhs.signature == rhs.signature && lhs.id == rhs.id
    }
}