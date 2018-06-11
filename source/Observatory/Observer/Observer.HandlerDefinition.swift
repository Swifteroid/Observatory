import Foundation

/// Handler definition provides a way of storing and managing individual notification handlers, most properties
/// represent arguments passed into `NotificationCenter.addObserverForName` method.
public protocol ObserverHandlerDefinition
{
    var isActive: Bool { get }
}

extension ObserverHandlerDefinition
{
    public var isInactive: Bool {
        return !self.isActive
    }
}