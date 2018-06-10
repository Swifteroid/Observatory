import Foundation

public protocol Observer
{
    var active: Bool { get }
    var inactive: Bool { get }
}

extension Observer
{
    public var inactive: Bool {
        return !self.active
    }
}

open class AbstractObserver: Observer
{
    public init() {}

    /// Specifies whether the observer is active or not.
    open internal(set) var active: Bool = false
}