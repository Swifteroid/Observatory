import Foundation
import Carbon

open class HotkeyObserverHandlerDefinition: ObserverHandlerDefinitionProtocol
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

    open let hotkey: KeyboardHotkey

    open let handler: Handler

    // MARK: -

    open private(set) var hotkeyIdentifier: EventHotKeyID!

    open private(set) var hotkeyReference: EventHotKeyRef!

    open private(set) var eventHandler: EventHandlerRef!

    // MARK: -

    open private(set) var active: Bool = false

    @discardableResult open func activate(_ newValue: Bool = true) throws -> Self {
        if newValue == self.active { return self }
        self.active = newValue
        return try self.update()
    }

    @discardableResult open func deactivate() throws -> Self {
        return try self.activate(false)
    }

    // MARK: -

    open private(set) var ignored: Bool = false

    @discardableResult open func ignore(_ newValue: Bool = true) throws -> Self {
        if newValue == self.ignored { return self }
        self.ignored = newValue
        return try self.update()
    }

    @discardableResult open func unignore() throws -> Self {
        return try self.ignore(false)
    }

    // MARK: -

    @discardableResult private func update() throws -> Self {
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

        let identifier: EventHotKeyID = EventHotKeyID(signature: 0, id: type(of: self).constructUniqueHotkeyIdentifier())
        var reference: EventHotKeyRef? = nil

        let status: OSStatus = RegisterEventHotKey(UInt32(self.hotkey.key), self.hotkey.modifier, identifier, GetApplicationEventTarget(), OptionBits(0), &reference)

        if Int(status) == eventHotKeyExistsErr {
            throw Error.hotkeyAlreadyRegistered
        } else if status != Darwin.noErr {
            throw Error.hotkeyRegisterFail(status: status)
        }

        self.hotkeyIdentifier = identifier
        self.hotkeyReference = reference
    }

    private func unregisterEventHotkey() throws {
        let status: OSStatus = UnregisterEventHotKey(self.hotkeyReference)
        guard status == Darwin.noErr else { throw Error.hotkeyUnregisterFail(status: status) }

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
            _ = try? self.deactivate()
        }
    }
}

public func ==(lhs: HotkeyObserverHandlerDefinition, rhs: HotkeyObserverHandlerDefinition) -> Bool {
    return lhs.hotkey == rhs.hotkey
}

// MARK: -

extension HotkeyObserverHandlerDefinition
{
    public enum Error: Swift.Error
    {
        case hotkeyAlreadyRegistered
        case hotkeyRegisterFail(status: OSStatus)
        case hotkeyUnregisterFail(status: OSStatus)
    }
}