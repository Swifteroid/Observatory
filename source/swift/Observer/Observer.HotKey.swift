import Foundation
import Carbon

/*
Useful resources on how to implement shortcuts and work with carbon events.

https://github.com/nathan/hush/blob/master/Hush/HotKey.swift
http://dbachrach.com/blog/2005/11/program-global-hotkeys-in-cocoa-easily/
http://stackoverflow.com/a/401244/458356 – How to Capture / Post system-wide Keyboard / Mouse events under Mac OS X?
http://stackoverflow.com/a/4640190/458356 – OSX keyboard shortcut background application
http://stackoverflow.com/a/34864422/458356
*/

private func getEventHotKeyId(event: EventRef) -> EventHotKeyID {
    let pointer: UnsafeMutablePointer<EventHotKeyID> = UnsafeMutablePointer.alloc(1)
    GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, sizeof(EventHotKeyID), nil, pointer)
    return pointer.memory
}

public class HotKeyObserver: Observer
{

    private var eventHandlerReference: EventHandlerRef!

    // MARK: -

    internal var definitions: [HandlerDefinition] = []

    // MARK: -

    override public var active: Bool {
        didSet {
            if active == oldValue {
                return
            } else if active {
                try! self.activate()
            } else if !self.active {
                try! self.deactivate()
            }
        }
    }

    private func activate() throws {

        // Before we can register any hot keys we must register an event handler with carbon framework.

        var eventType: EventTypeSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        var eventHandler: EventHandlerRef = nil

        let eventHandlerPointer: UnsafeMutablePointer<(EventHotKeyID) -> ()> = UnsafeMutablePointer.alloc(1)
        eventHandlerPointer.initialize(self.handleHotKey)

        // Create universal procedure pointer, so it can be passed to C.

        let eventHandlerUpp: EventHandlerUPP = { (nextHandler: EventHandlerCallRef, event: EventRef, pointer: UnsafeMutablePointer<Void>) -> OSStatus in
            UnsafeMutablePointer<(EventHotKeyID) -> ()>(pointer).memory(getEventHotKeyId(event))
            return CallNextEventHandler(nextHandler, event)
        }

        guard let status: OSStatus = InstallEventHandler(GetApplicationEventTarget(), eventHandlerUpp, 1, &eventType, eventHandlerPointer, &eventHandler) where status == Darwin.noErr else {
            throw Error.UppInstallFailed
        }

        self.eventHandlerReference = eventHandler

        // Now we can activate handlers.

        for definition in self.definitions {
            try! definition.activate(eventHandler)
        }
    }

    private func deactivate() throws {

        // Deactivation goes in reverse, first deactivate definitions…

        for definition in self.definitions {
            try! definition.deactivate()
        }

        // Than remove the event handler.

        guard let status: OSStatus = RemoveEventHandler(self.eventHandlerReference) where status == Darwin.noErr else {
            throw Error.UppRemoveFail
        }

        self.eventHandlerReference = nil
    }

    private func handleHotKey(identifier: EventHotKeyID) {
        for definition in self.definitions {
            if definition.hotKeyIdentifier == identifier {
                (definition.handler as! Block)()
                break
            }
        }
    }

    // MARK: -

    public convenience init(active: Bool) {
        self.init()
        self.active = active
    }

    // MARK: -

    public func add(key: UInt32, modifier: UInt32, handler: Any) throws -> HotKeyObserver {
        var hotKeyHandler: Any

        if handler is Block || handler is ConventionBlock {
            hotKeyHandler = handler
        } else {
            throw Observer.Error.UnrecognisedHandlerSignature
        }

        let definition: HandlerDefinition = HandlerDefinition(key: key, modifier: modifier, handler: hotKeyHandler)

        // Make sure we're not adding the same definition twice and register observer with notification center
        // if observer is active. Comparison of handlers would only work with @convention(block) signatures.

        if self.definitions.contains(definition) {
            return self
        }

        self.definitions.append(self.active ? (try! definition.activate(self.eventHandlerReference)) : definition)

        return self
    }

    public func remove(key: UInt32, modifier: UInt32, handler: Any?, strict: Bool) -> Self {
        var i: Int = 0
        var n: Int = self.definitions.count

        while i < n {
            if let definition: HandlerDefinition = self.definitions[i] where (definition.key == key) && (definition.modifier == modifier) && (handler == nil && !strict || handler != nil && self.dynamicType.compareBlocks(definition.handler, handler)) {
                self.definitions.removeAtIndex(i)
                n -= 1
            } else {
                i += 1
            }
        }

        return self
    }

    public func remove(key: UInt32, modifier: UInt32, handler: Any) -> Self {
        return self.remove(key, modifier: modifier, handler: handler, strict: false)
    }

    public func remove(key: UInt32, modifier: UInt32) -> Self {
        return self.remove(key, modifier: modifier, handler: nil, strict: false)
    }
}

extension HotKeyObserver
{
    public class HandlerDefinition: Equatable, ObserverHandlerDefinitionProtocol
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

        public func activate(eventHandler: EventHandlerRef) throws -> Self {
            guard !self.active else {
                return self
            }

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
}

extension HotKeyObserver
{
    public enum Error: ErrorType
    {
        case HotKeyRegisterFail
        case HotKeyUnregisterFail
        case UppInstallFailed
        case UppRemoveFail
    }
}

public func ==(left: HotKeyObserver.HandlerDefinition, right: HotKeyObserver.HandlerDefinition) -> Bool {
    return true &&
        left.key == right.key &&
        left.modifier == right.modifier
}