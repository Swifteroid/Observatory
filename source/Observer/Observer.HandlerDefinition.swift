import Foundation

/// Handler definition provides a way of storing and managing individual notification handlers, most properties
/// represent arguments passed into `NotificationCenter.addObserverForName` method.

public protocol ObserverHandlerDefinitionProtocol: Equatable
{
    var active: Bool { get }
    var inactive: Bool { get }
}

extension ObserverHandlerDefinitionProtocol
{
    public var inactive: Bool {
        return !self.active
    }
}