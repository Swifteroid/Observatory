import Foundation

public protocol Observer {

    /// Indicates whether observer is active or not.
    var isActive: Bool { get }
}

extension Observer {
    public var isInactive: Bool {
        !self.isActive
    }
}

open class AbstractObserver: Observer {
    public init() {}

    open internal(set) var isActive: Bool = false
}
