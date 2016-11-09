import Foundation

public class HotkeyObserverHandlerDefinitionFactory
{
    public var hotkey: KeyboardHotkey
    public var handler: Any

    // MARK: -

    public init(hotkey: KeyboardHotkey, handler: Any) {
        self.hotkey = hotkey
        self.handler = handler
    }

    // MARK: -

    public func construct() throws -> HotkeyObserverHandlerDefinition {
        var handler: Any

        if self.handler is ObserverHandler || self.handler is ObserverConventionHandler {
            handler = self.handler
        } else {
            throw Observer.Error.UnrecognisedHandlerSignature
        }

        return HotkeyObserverHandlerDefinition(hotkey: self.hotkey, handler: handler)
    }
}