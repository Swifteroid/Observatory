import Foundation

/// Weak wrapper around the object.
internal class Weak
{
    internal init(value: AnyObject) { self.value = value }
    internal weak var value: AnyObject?
}