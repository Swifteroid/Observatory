import Foundation
import Carbon

extension HotkeyObserver
{
    public struct Handler
    {
        public typealias Signature = (KeyboardHotkey) -> ()

        open class Definition: ObserverHandlerDefinition
        {
            public init(hotkey: KeyboardHotkey, handler: @escaping Signature) {
                self.hotkey = hotkey
                self.handler = handler
            }

            deinit {
                self.deactivate()
            }

            // MARK: -

            /// Keeps global count track of unique ids used for hotkeys.

            private static var uniqueHotkeyId: UInt32 = 0

            private static func constructUniqueHotkeyIdentifier() -> UInt32 {
                defer { self.uniqueHotkeyId += 1 }
                return self.uniqueHotkeyId
            }

            // MARK: -

            open let hotkey: KeyboardHotkey
            open let handler: Signature

            // MARK: -

            open private(set) var hotkeyIdentifier: EventHotKeyID!
            open private(set) var hotkeyReference: EventHotKeyRef!
            open private(set) var eventHandler: EventHandlerRef!
            open private(set) var error: Swift.Error?

            // MARK: -

            open private(set) var active: Bool = false

            @discardableResult open func activate(_ newValue: Bool = true) -> Self {
                if newValue == self.active { return self }
                return self.update(active: newValue, ignored: self.ignored)
            }

            @discardableResult open func deactivate() -> Self {
                return self.activate(false)
            }

            // MARK: -

            open private(set) var ignored: Bool = false

            @discardableResult open func ignore(_ newValue: Bool = true) -> Self {
                if newValue == self.ignored { return self }
                return self.update(active: self.active, ignored: newValue)
            }

            @discardableResult open func unignore() -> Self {
                return self.ignore(false)
            }

            // MARK: -

            @discardableResult private func update(active: Bool, ignored: Bool) -> Self {
                let newActive: Bool = active && !ignored
                let oldActive: Bool = self.hotkeyIdentifier ?? nil != nil && self.hotkeyReference ?? nil != nil

                do {
                    if newActive && !oldActive {
                        try self.registerEventHotkey()
                    } else if !newActive && oldActive {
                        try self.unregisterEventHotkey()
                    }

                    self.error = nil
                    self.active = active
                    self.ignored = ignored
                } catch {
                    self.error = error
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

            public static func ==(lhs: Definition, rhs: Definition) -> Bool {
                return lhs.hotkey == rhs.hotkey
            }
        }
    }
}
// MARK: -

extension HotkeyObserver.Handler.Definition
{
    public enum Error: Swift.Error
    {
        case hotkeyAlreadyRegistered
        case hotkeyRegisterFail(status: OSStatus)
        case hotkeyUnregisterFail(status: OSStatus)
    }
}