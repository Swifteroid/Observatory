import Foundation

public class HotKeyObserverHandlerDefinitionFactory
{
    public var key: UInt32
    public var modifier: UInt32
    public var handler: Any

    // MARK: -

    public init(key: UInt32, modifier: UInt32, handler: Any) {
        self.key = key
        self.modifier = modifier
        self.handler = handler
    }

    // MARK: -

    public func construct() throws -> HotKeyObserverHandlerDefinition {
        var handler: Any

        if self.handler is ObserverHandler || self.handler is ObserverConventionHandler {
            handler = self.handler
        } else {
            throw Observer.Error.UnrecognisedHandlerSignature
        }

        return HotKeyObserverHandlerDefinition(key: self.key, modifier: self.modifier, handler: handler)
    }
}