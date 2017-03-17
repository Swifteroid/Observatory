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

private func hotkey(for event: EventRef) -> EventHotKeyID {
    let pointer: UnsafeMutablePointer<EventHotKeyID> = UnsafeMutablePointer.allocate(capacity: 1)
    GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, pointer)
    return pointer.pointee
}

// MARK: -

open class HotkeyObserver: Observer
{
    private typealias EventHandler = EventHandlerUPP
    private typealias EventHandlerPointer = EventHandlerRef
    private typealias EventHotkeyHandler = (EventHotKeyID) -> ()
    private typealias EventHotkeyHandlerPointer = UnsafeMutablePointer<EventHotkeyHandler>

    private var eventHandlerPointer: EventHandlerPointer?
    private var eventHotkeyHandlerPointer: EventHotkeyHandlerPointer?

    // MARK: -

    open internal(set) var definitions: [HotkeyObserverHandlerDefinition] = []

    // MARK: -

    override public init() {
        super.init()
        HotkeyCenter.default.register(observer: self)
    }

    public convenience init(active: Bool) throws {
        self.init()
        try self.activate(active)
    }

    // MARK: -

    @discardableResult open func activate(_ newValue: Bool = true) throws -> Self {
        if newValue == self.active { return self }

        // Before we can register any hot keys we must register an event handler with carbon framework. Deactivation goes
        // in reverse, first deactivate definitions then event handler.

        if newValue {
            let (eventHandler, eventHotkeyHandler) = try self.constructEventHandler()
            self.eventHandlerPointer = eventHandler
            self.eventHotkeyHandlerPointer = eventHotkeyHandler
            for definition in self.definitions { try definition.activate() }
        } else {
            for definition in self.definitions { try definition.deactivate() }
            try self.destructEventHandler(self.eventHandlerPointer!, eventHotkeyHandler: self.eventHotkeyHandlerPointer!)
            self.eventHandlerPointer = nil
            self.eventHotkeyHandlerPointer = nil
        }

        self.active = newValue
        return self
    }

    @discardableResult open func deactivate() throws -> Self {
        return try self.activate(false)
    }

    // MARK: -

    private func constructEventHandler() throws -> (EventHandlerPointer, EventHotkeyHandlerPointer) {
        var eventType: EventTypeSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let eventHandler: EventHandler
        var eventHandlerPointer: EventHandlerPointer? = nil
        let eventHotkeyHandlerPointer: UnsafeMutablePointer<EventHotkeyHandler> = UnsafeMutablePointer.allocate(capacity: 1)

        eventHandler = { (nextHandler: EventHandlerCallRef?, event: EventRef?, pointer: UnsafeMutableRawPointer?) -> OSStatus in
            UnsafeMutablePointer<EventHotkeyHandler>(OpaquePointer(pointer!)).pointee(hotkey(for: event!))
            return CallNextEventHandler(nextHandler, event)
        }

        eventHotkeyHandlerPointer.initialize(to: { [unowned self] (identifier: EventHotKeyID) in
            for definition in self.definitions {
                if definition.hotkeyIdentifier == identifier {
                    (definition.handler.normalised as! HotkeyObserverHandler)(definition.hotkey)
                    break
                }
            }
        })

        // Create universal procedure pointer, so it can be passed to C.

        let status: OSStatus = InstallEventHandler(GetApplicationEventTarget(), eventHandler, 1, &eventType, eventHotkeyHandlerPointer, &eventHandlerPointer)
        guard status == Darwin.noErr else { throw Error.uppInstallFailed }

        return (eventHandlerPointer!, eventHotkeyHandlerPointer)
    }

    private func destructEventHandler(_ eventHandler: EventHandlerPointer, eventHotkeyHandler: EventHotkeyHandlerPointer) throws {
        let status: OSStatus = RemoveEventHandler(eventHandler)
        guard status == Darwin.noErr else { throw Error.uppRemoveFail }

        eventHotkeyHandler.deallocate(capacity: 1)
    }

    // MARK: -

    @discardableResult open func add(hotkey: KeyboardHotkey, handler: Any) throws -> Self {
        let factory: HotkeyObserverHandlerDefinitionFactory = HotkeyObserverHandlerDefinitionFactory(hotkey: hotkey, handler: handler)
        let definition: HotkeyObserverHandlerDefinition = try factory.construct()

        guard !self.definitions.contains(definition) else { return self }
        self.definitions.append(self.active ? (try definition.activate()) : definition)

        return self
    }

    @discardableResult open func remove(hotkey: KeyboardHotkey, handler: Any?, strict: Bool) throws -> Self {
        for (index, definition) in self.filter(hotkey: hotkey, handler: handler, strict: strict).reversed() {
            try definition.deactivate()
            self.definitions.remove(at: index)
        }

        return self
    }

    @discardableResult open func remove(hotkey: KeyboardHotkey, handler: Any) throws -> Self {
        return try self.remove(hotkey: hotkey, handler: handler, strict: false)
    }

    @discardableResult open func remove(hotkey: KeyboardHotkey) throws -> Self {
        return try self.remove(hotkey: hotkey, handler: nil, strict: false)
    }

    // MARK: -

    private func filter(hotkey: KeyboardHotkey, handler: Any?, strict: Bool) -> [(offset: Int, element: HotkeyObserverHandlerDefinition)] {
        return self.definitions.enumerated().filter({ (_: Int, definition: HotkeyObserverHandlerDefinition) in
            return true &&
                (definition.hotkey == hotkey) &&
                (handler == nil && !strict || handler != nil && type(of: self).compareBlocks(definition.handler, handler!))
        })
    }
}

// MARK: -

extension HotkeyObserver
{
    public enum Error: Swift.Error
    {
        case uppInstallFailed
        case uppRemoveFail
    }
}