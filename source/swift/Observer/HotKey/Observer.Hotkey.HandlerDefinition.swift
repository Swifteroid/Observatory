import Foundation
import Carbon

public class HotkeyObserverHandlerDefinition: ObserverHandlerDefinitionProtocol
{
    /*
    Keeps global count track of unique ids used for hotkeys.
    */
    private static var uniqueHotkeyId: UInt32 = 0

    private static func constructUniqueHotkeyIdentifier() -> UInt32 {
        defer { self.uniqueHotkeyId += 1 }
        return self.uniqueHotkeyId
    }

    // MARK: -

    public let hotkey: KeyboardHotkey

    public let handler: Any

    // MARK: -

    public private(set) var hotkeyIdentifier: EventHotKeyID!

    public private(set) var hotkeyReference: EventHotKeyRef!

    public private(set) var eventHandler: EventHandlerRef!

    // MARK: -

    public private(set) var active: Bool = false

    public func activate(eventHandler: EventHandlerRef) throws -> HotkeyObserverHandlerDefinition {
        guard self.inactive else {
            return self
        }

        // Todo: should use proper signature, find examples…

        let identifier: EventHotKeyID = EventHotKeyID(signature: 0, id: self.dynamicType.constructUniqueHotkeyIdentifier())
        var reference: EventHotKeyRef = nil

        guard let status: OSStatus = RegisterEventHotKey(self.hotkey.key, self.hotkey.modifier, identifier, GetApplicationEventTarget(), OptionBits(0), &reference) where status == Darwin.noErr else {
            throw Error.HotkeyRegisterFail
        }

        self.hotkeyIdentifier = identifier
        self.hotkeyReference = reference
        self.active = true

        return self
    }

    public func deactivate() throws -> Self {
        guard self.active else {
            return self
        }

        guard let status: OSStatus = UnregisterEventHotKey(self.hotkeyReference) where status == Darwin.noErr else {
            throw Error.HotkeyUnregisterFail
        }

        self.hotkeyIdentifier = nil
        self.active = false

        return self
    }

    // MARK: -

    public init(hotkey: KeyboardHotkey, handler: Any) {
        self.hotkey = hotkey
        self.handler = handler
    }

    deinit {
        if self.active {
            try! self.deactivate()
        }
    }
}

public func ==(lhs: HotkeyObserverHandlerDefinition, rhs: HotkeyObserverHandlerDefinition) -> Bool {
    return lhs.hotkey == rhs.hotkey
}

// MARK: -

extension HotkeyObserverHandlerDefinition
{
    public enum Error: ErrorType
    {
        case HotkeyRegisterFail
        case HotkeyUnregisterFail
    }
}