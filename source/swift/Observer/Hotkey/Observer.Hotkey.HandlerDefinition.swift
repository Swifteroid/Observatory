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

    public typealias Handler = (original: Any, normalised: Any)

    public let hotkey: KeyboardHotkey

    public let handler: Handler

    // MARK: -

    public private(set) var hotkeyIdentifier: EventHotKeyID!

    public private(set) var hotkeyReference: EventHotKeyRef!

    public private(set) var eventHandler: EventHandlerRef!

    // MARK: -

    public var ignored: Bool = false {
        didSet {
            if self.ignored == oldValue { return }
            try! self.update()
        }
    }

    public private(set) var active: Bool = false

    public func activate() throws -> Self {
        guard !self.active else { return self }
        self.active = true
        return try self.update()
    }

    public func deactivate() throws -> Self {
        guard self.active else { return self }
        self.active = false
        return try self.update()
    }

    private func update() throws -> Self {
        let newActive: Bool = self.active && !self.ignored
        let oldActive: Bool = self.hotkeyIdentifier ?? nil != nil && self.hotkeyReference ?? nil != nil

        if newActive && !oldActive {
            try self.registerEventHotkey()
        } else if !newActive && oldActive {
            try self.unregisterEventHotkey()
        }

        return self
    }

    // MARK: -

    private func registerEventHotkey() throws {

        // Todo: should use proper signature, find examples…

        let identifier: EventHotKeyID = EventHotKeyID(signature: 0, id: self.dynamicType.constructUniqueHotkeyIdentifier())
        var reference: EventHotKeyRef = nil

        if let status: OSStatus = RegisterEventHotKey(UInt32(self.hotkey.key), self.hotkey.modifier, identifier, GetApplicationEventTarget(), OptionBits(0), &reference) where status != Darwin.noErr {
            if Int(status) == eventHotKeyExistsErr {
                throw Error.HotkeyAlreadyRegistered
            } else {
                throw Error.HotkeyRegisterFail(status: status)
            }
        }

        self.hotkeyIdentifier = identifier
        self.hotkeyReference = reference
    }

    private func unregisterEventHotkey() throws {
        if let status: OSStatus = UnregisterEventHotKey(self.hotkeyReference) where status != Darwin.noErr {
            throw Error.HotkeyUnregisterFail(status: status)
        }

        self.hotkeyIdentifier = nil
        self.hotkeyReference = nil
    }

    // MARK: -

    public init(hotkey: KeyboardHotkey, handler: Handler) {
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
        case HotkeyAlreadyRegistered
        case HotkeyRegisterFail(status: OSStatus)
        case HotkeyUnregisterFail(status: OSStatus)
    }
}