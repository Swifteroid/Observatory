import Foundation
import Carbon

public class HotKeyObserverHandlerDefinition: ObserverHandlerDefinitionProtocol
{
    /*
    Keeps global count track of unique ids used for hot keys.
    */
    private static var uniqueHotKeyId: UInt32 = 0

    private static func constructUniqueHotKeyId() -> UInt32 {
        defer { self.uniqueHotKeyId += 1 }
        return self.uniqueHotKeyId
    }

    // MARK: -

    public let key: UInt32

    public let modifier: UInt32

    public let handler: Any

    // MARK: -

    public private(set) var hotKeyIdentifier: EventHotKeyID!

    public private(set) var hotKeyReference: EventHotKeyRef!

    public private(set) var eventHandler: EventHandlerRef!

    // MARK: -

    public private(set) var active: Bool = false

    public func activate(eventHandler: EventHandlerRef) throws -> HotKeyObserverHandlerDefinition {
        guard self.inactive else {
            return self
        }

        // Todo: should use proper signature, find examples…

        let identifier: EventHotKeyID = EventHotKeyID(signature: 0, id: self.dynamicType.constructUniqueHotKeyId())
        var reference: EventHotKeyRef = nil

        guard let status: OSStatus = RegisterEventHotKey(self.key, self.modifier, identifier, GetApplicationEventTarget(), OptionBits(0), &reference) where status == Darwin.noErr else {
            throw Error.HotKeyRegisterFail
        }

        self.hotKeyIdentifier = identifier
        self.hotKeyReference = reference
        self.active = true

        return self
    }

    public func deactivate() throws -> Self {
        guard self.active else {
            return self
        }

        guard let status: OSStatus = UnregisterEventHotKey(self.hotKeyReference) where status == Darwin.noErr else {
            throw Error.HotKeyUnregisterFail
        }

        self.hotKeyIdentifier = nil
        self.active = false

        return self
    }

    // MARK: -

    public init(key: UInt32, modifier: UInt32, handler: Any) {
        self.key = key
        self.modifier = modifier
        self.handler = handler
    }

    deinit {
        if self.active {
            try! self.deactivate()
        }
    }
}

public func ==(lhs: HotKeyObserverHandlerDefinition, rhs: HotKeyObserverHandlerDefinition) -> Bool {
    return true &&
        lhs.key == rhs.key &&
        lhs.modifier == rhs.modifier
}

// MARK: -

extension HotKeyObserverHandlerDefinition
{
    public enum Error: ErrorType
    {
        case HotKeyRegisterFail
        case HotKeyUnregisterFail
    }
}