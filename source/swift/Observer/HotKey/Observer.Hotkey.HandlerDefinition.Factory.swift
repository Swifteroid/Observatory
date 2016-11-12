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
        var definition: HotkeyObserverHandlerDefinition!
        var handler: Any

        if self.handler is ObserverHandler {
            handler = { (hotkey: KeyboardHotkey) in (definition.handler.original as! ObserverHandler)() }
        } else if self.handler is ObserverConventionHandler {
            handler = { (hotkey: KeyboardHotkey) in (definition.handler.original as! ObserverConventionHandler)() }
        } else if self.handler is HotkeyObserverHandler {
            handler = self.handler
        } else {
            throw Observer.Error.UnrecognisedHandlerSignature
        }

        definition = HotkeyObserverHandlerDefinition(hotkey: self.hotkey, handler: (original: self.handler, normalised: handler))
        return definition
    }
}