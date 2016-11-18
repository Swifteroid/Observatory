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
        let originalHandler: Any = self.handler
        var normalisedHandler: Any

        if originalHandler is ObserverHandler {
            normalisedHandler = { (hotkey: KeyboardHotkey) in (originalHandler as! ObserverHandler)() }
        } else if originalHandler is ObserverConventionHandler {
            normalisedHandler = { (hotkey: KeyboardHotkey) in (originalHandler as! ObserverConventionHandler)() }
        } else if originalHandler is HotkeyObserverHandler {
            normalisedHandler = originalHandler
        } else {
            throw Observer.Error.UnrecognisedHandlerSignature
        }

        definition = HotkeyObserverHandlerDefinition(hotkey: self.hotkey, handler: (original: originalHandler, normalised: normalisedHandler))
        return definition
    }
}