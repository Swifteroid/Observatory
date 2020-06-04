import Foundation
import Carbon

extension HotkeyObserver {
    public struct Handler {
        public typealias Signature = (KeyboardHotkey) -> Void

        open class Definition: ObserverHandlerDefinition {
            deinit {
                self.deactivate()
            }

            public init(hotkey: KeyboardHotkey, handler: @escaping Signature) {
                self.hotkey = hotkey
                self.handler = handler
            }

            /// Keeps global count track of unique ids used for hotkeys.
            private static var uniqueHotkeyIdentifier: UInt32 = 0

            private static func constructUniqueHotkeyIdentifier() -> UInt32 {
                defer { self.uniqueHotkeyIdentifier += 1 }
                return self.uniqueHotkeyIdentifier
            }

            public let hotkey: KeyboardHotkey
            public let handler: Signature

            open private(set) var hotkeyIdentifier: EventHotKeyID!
            open private(set) var hotkeyReference: EventHotKeyRef!
            open private(set) var eventHandler: EventHandlerRef!
            open private(set) var error: Swift.Error?

            open private(set) var isActive: Bool = false

            @discardableResult open func activate(_ newValue: Bool = true) -> Self {
                if newValue == self.isActive { return self }
                return self.update(active: newValue, ignored: self.isIgnored)
            }

            @discardableResult open func deactivate() -> Self {
                self.activate(false)
            }

            open private(set) var isIgnored: Bool = false

            @discardableResult open func ignore(_ newValue: Bool = true) -> Self {
                if newValue == self.isIgnored { return self }
                return self.update(active: self.isActive, ignored: newValue)
            }

            @discardableResult open func unignore() -> Self {
                self.ignore(false)
            }

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
                    self.isActive = active
                    self.isIgnored = ignored
                } catch {
                    self.error = error
                }

                return self
            }

            private func registerEventHotkey() throws {

                // Todo: should use proper signature, find examples…

                let identifier: EventHotKeyID = EventHotKeyID(signature: 0, id: Self.constructUniqueHotkeyIdentifier())
                var reference: EventHotKeyRef?

                let status: OSStatus = RegisterEventHotKey(UInt32(self.hotkey.key.rawValue), UInt32(self.hotkey.modifier.rawValue), identifier, GetApplicationEventTarget(), OptionBits(0), &reference)

                if Int(status) == eventHotKeyExistsErr {
                    throw Error.hotkeyAlreadyRegistered
                } else if status != Darwin.noErr {
                    throw Error.cannotRegisterHotkey(status: status)
                }

                self.hotkeyIdentifier = identifier
                self.hotkeyReference = reference
            }

            private func unregisterEventHotkey() throws {
                let status: OSStatus = UnregisterEventHotKey(self.hotkeyReference)
                guard status == Darwin.noErr else { throw Error.cannotUnregisterHotkey(status: status) }

                self.hotkeyIdentifier = nil
                self.hotkeyReference = nil
            }
        }
    }
}

/// Convenience initializers.
extension HotkeyObserver.Handler.Definition {
    public convenience init(hotkey: KeyboardHotkey, handler: @escaping () -> Void) {
        self.init(hotkey: hotkey, handler: { _ in handler() })
    }
}

extension HotkeyObserver.Handler.Definition {
    public enum Error: Swift.Error {
        case hotkeyAlreadyRegistered
        case cannotRegisterHotkey(status: OSStatus)
        case cannotUnregisterHotkey(status: OSStatus)
    }
}
