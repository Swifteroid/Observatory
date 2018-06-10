import Foundation
import Carbon

/// Useful resources on how to implement shortcuts and work with carbon events.
/// 
/// https://github.com/nathan/hush/blob/master/Hush/HotKey.swift
/// http://dbachrach.com/blog/2005/11/program-global-hotkeys-in-cocoa-easily/
/// http://stackoverflow.com/a/401244/458356 – How to Capture / Post system-wide Keyboard / Mouse events under Mac OS X?
/// http://stackoverflow.com/a/4640190/458356 – OSX keyboard shortcut background application
/// http://stackoverflow.com/a/34864422/458356
private func hotkey(for event: EventRef) -> EventHotKeyID {
    let pointer: UnsafeMutablePointer<EventHotKeyID> = UnsafeMutablePointer.allocate(capacity: 1)
    GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, pointer)
    return pointer.pointee
}

open class HotkeyObserver: AbstractObserver
{
    private typealias EventHandler = EventHandlerUPP
    private typealias EventHandlerPointer = EventHandlerRef
    private typealias EventHotkeyHandler = (EventHotKeyID) -> ()
    private typealias EventHotkeyHandlerPointer = UnsafeMutablePointer<EventHotkeyHandler>

    override public init() {
        super.init()
        HotkeyCenter.default.register(observer: self)
    }

    public convenience init(active: Bool) {
        self.init()
        self.activate(active)
    }

    private var eventHandlerPointer: EventHandlerPointer?
    private var eventHotkeyHandlerPointer: EventHotkeyHandlerPointer?

    open internal(set) var definitions: [Handler.Definition] = []

    @discardableResult open func add(definition: Handler.Definition) -> Self {
        self.definitions.append(definition.activate(self.active))
        return self
    }

    @discardableResult open func add(definitions: [Handler.Definition]) -> Self {
        for definition in definitions { self.add(definition: definition) }
        return self
    }

    @discardableResult open func remove(definition: Handler.Definition) -> Self {
        self.definitions.enumerated().first(where: { $0.1 === definition }).map({ self.definitions.remove(at: $0.0) })?.deactivate()
        return self
    }

    @discardableResult open func remove(definitions: [Handler.Definition]) -> Self {
        for definition in definitions { self.remove(definition: definition) }
        return self
    }

    override open var active: Bool {
        get { return super.active }
        set { self.activate(newValue) }
    }

    @discardableResult open func activate(_ newValue: Bool = true) -> Self {
        if newValue == self.active { return self }
        return self.update(active: newValue)
    }

    @discardableResult open func deactivate() -> Self {
        return self.activate(false)
    }

    open private(set) var error: Swift.Error?

    @discardableResult private func update(active: Bool) -> Self {

        // Before we can register any hot keys we must register an event handler with carbon framework. Deactivation goes
        // in reverse, first deactivate definitions then event handler.

        do {
            if active {
                let (eventHandler, eventHotkeyHandler) = try self.constructEventHandler()
                self.eventHandlerPointer = eventHandler
                self.eventHotkeyHandlerPointer = eventHotkeyHandler
                for definition in self.definitions { definition.activate() }
            } else {
                for definition in self.definitions { definition.deactivate() }
                try self.destructEventHandler(self.eventHandlerPointer!, eventHotkeyHandler: self.eventHotkeyHandlerPointer!)
                self.eventHandlerPointer = nil
                self.eventHotkeyHandlerPointer = nil
            }

            self.error = nil
            super.active = active
        } catch {
            self.error = error
        }

        return self
    }

    private func constructEventHandler() throws -> (EventHandlerPointer, EventHotkeyHandlerPointer) {
        var eventType: EventTypeSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let eventHandler: EventHandler
        var eventHandlerPointer: EventHandlerPointer? = nil
        let eventHotkeyHandlerPointer: UnsafeMutablePointer<EventHotkeyHandler> = UnsafeMutablePointer.allocate(capacity: 1)

        eventHandler = { (nextHandler: EventHandlerCallRef?, event: EventRef?, pointer: UnsafeMutableRawPointer?) -> OSStatus in
            UnsafeMutablePointer<EventHotkeyHandler>(OpaquePointer(pointer!)).pointee(hotkey(for: event!))
            return CallNextEventHandler(nextHandler, event)
        }

        eventHotkeyHandlerPointer.initialize(to: { [weak self] (identifier: EventHotKeyID) in
            self?.definitions.filter({ $0.hotkeyIdentifier == identifier }).forEach({ $0.handler($0.hotkey) })
        })

        // Create universal procedure pointer, so it can be passed to C.

        let status: OSStatus = InstallEventHandler(GetApplicationEventTarget(), eventHandler, 1, &eventType, eventHotkeyHandlerPointer, &eventHandlerPointer)
        guard status == Darwin.noErr else { throw Error.uppInstallFailed }

        return (eventHandlerPointer!, eventHotkeyHandlerPointer)
    }

    private func destructEventHandler(_ eventHandler: EventHandlerPointer, eventHotkeyHandler: EventHotkeyHandlerPointer) throws {
        let status: OSStatus = RemoveEventHandler(eventHandler)
        guard status == Darwin.noErr else { throw Error.uppRemoveFail }

        eventHotkeyHandler.deinitialize(count: 1)
        eventHotkeyHandler.deallocate()
    }
}

extension HotkeyObserver
{
    @discardableResult open func add(hotkey: KeyboardHotkey, handler: @escaping () -> ()) -> Self {
        return self.add(definition: Handler.Definition(hotkey: hotkey, handler: { _ in handler() }))
    }

    @discardableResult open func add(hotkey: KeyboardHotkey, handler: @escaping (KeyboardHotkey) -> ()) -> Self {
        return self.add(definition: Handler.Definition(hotkey: hotkey, handler: handler))
    }

    @discardableResult open func remove(hotkey: KeyboardHotkey) -> Self {
        self.definitions.filter({ $0.hotkey == hotkey }).forEach({ _ = self.remove(definition: $0) })
        return self
    }
}

extension HotkeyObserver
{
    public enum Error: Swift.Error
    {
        case uppInstallFailed
        case uppRemoveFail
    }
}