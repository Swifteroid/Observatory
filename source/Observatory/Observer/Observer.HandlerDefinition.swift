import Foundation

/// Handler definition provides a way of storing and managing individual notification handlers, most properties
/// represent arguments passed into `NotificationCenter.addObserverForName` method.

public protocol ObserverHandlerDefinition
{
    var active: Bool { get }
    var inactive: Bool { get }
}

extension ObserverHandlerDefinition
{
    public var inactive: Bool {
        return !self.active
    }
}