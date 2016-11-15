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

private func getEventHotkey(event: EventRef) -> EventHotKeyID {
    let pointer: UnsafeMutablePointer<EventHotKeyID> = UnsafeMutablePointer.alloc(1)
    GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, sizeof(EventHotKeyID), nil, pointer)
    return pointer.memory
}

// MARK: -

public class HotkeyObserver: Observer
{
    private typealias EventHandler = EventHandlerUPP
    private typealias EventHandlerPointer = EventHandlerRef
    private typealias EventHotkeyHandler = (EventHotKeyID) -> ()
    private typealias EventHotkeyHandlerPointer = UnsafeMutablePointer<EventHotkeyHandler>

    private var eventHandlerPointer: EventHandlerPointer!
    private var eventHotkeyHandlerPointer: EventHotkeyHandlerPointer!

    // MARK: -

    public internal(set) var definitions: [HotkeyObserverHandlerDefinition] = []

    // MARK: -

    override internal func activate() {

        // Before we can register any hot keys we must register an event handler with carbon framework.

        let (eventHandler, eventHotkeyHandler) = try! self.constructEventHandler()

        self.eventHandlerPointer = eventHandler
        self.eventHotkeyHandlerPointer = eventHotkeyHandler

        for definition in self.definitions {
            try! definition.activate()
        }
    }

    override internal func deactivate() {

        // Deactivation goes in reverse, first deactivate definitions then event handler.

        for definition in self.definitions {
            try! definition.deactivate()
        }

        try! self.destructEventHandler(self.eventHandlerPointer, eventHotkeyHandler: self.eventHotkeyHandlerPointer)

        self.eventHandlerPointer = nil
        self.eventHotkeyHandlerPointer = nil
    }

    // MARK: -

    private func constructEventHandler() throws -> (EventHandlerPointer, EventHotkeyHandlerPointer) {
        var eventType: EventTypeSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let eventHandler: EventHandler
        var eventHandlerPointer: EventHandlerPointer = nil
        let eventHotkeyHandlerPointer: UnsafeMutablePointer<EventHotkeyHandler> = UnsafeMutablePointer.alloc(1)

        eventHandler = { (nextHandler: EventHandlerCallRef, event: EventRef, pointer: UnsafeMutablePointer<Void>) -> OSStatus in
            UnsafeMutablePointer<EventHotkeyHandler>(pointer).memory(getEventHotkey(event))
            return CallNextEventHandler(nextHandler, event)
        }

        eventHotkeyHandlerPointer.initialize({ [unowned self] (identifier: EventHotKeyID) in
            for definition in self.definitions {
                if definition.hotkeyIdentifier == identifier {
                    (definition.handler.normalised as! HotkeyObserverHandler)(hotkey: definition.hotkey)
                    break
                }
            }
        })

        // Create universal procedure pointer, so it can be passed to C.

        guard let status: OSStatus = InstallEventHandler(GetApplicationEventTarget(), eventHandler, 1, &eventType, eventHotkeyHandlerPointer, &eventHandlerPointer) where status == Darwin.noErr else {
            throw Error.UppInstallFailed
        }

        return (eventHandlerPointer, eventHotkeyHandlerPointer)
    }

    private func destructEventHandler(eventHandler: EventHandlerPointer, eventHotkeyHandler: EventHotkeyHandlerPointer) throws {
        guard let status: OSStatus = RemoveEventHandler(eventHandler) where status == Darwin.noErr else {
            throw Error.UppRemoveFail
        }

        eventHotkeyHandler.dealloc(1)
    }

    // MARK: -

    public func add(hotkey: KeyboardHotkey, handler: Any) throws -> HotkeyObserver {
        let factory: HotkeyObserverHandlerDefinitionFactory = HotkeyObserverHandlerDefinitionFactory(hotkey: hotkey, handler: handler)
        let definition: HotkeyObserverHandlerDefinition = try! factory.construct()

        guard !self.definitions.contains(definition) else { return self }
        self.definitions.append(self.active ? (try! definition.activate()) : definition)

        return self
    }

    public func remove(hotkey: KeyboardHotkey, handler: Any?, strict: Bool) -> Self {
        for (index, _) in self.filter(hotkey, handler: handler, strict: strict).reverse() {
            self.definitions.removeAtIndex(index)
        }

        return self
    }

    public func remove(hotkey: KeyboardHotkey, handler: Any) -> Self {
        return self.remove(hotkey, handler: handler, strict: false)
    }

    public func remove(hotkey: KeyboardHotkey) -> Self {
        return self.remove(hotkey, handler: nil, strict: false)
    }

    // MARK: -

    private func filter(hotkey: KeyboardHotkey, handler: Any?, strict: Bool) -> [(index: Int, element: HotkeyObserverHandlerDefinition)] {
        return self.definitions.enumerate().filter({ (_: Int, definition: HotkeyObserverHandlerDefinition) in
            return true &&
                (definition.hotkey == hotkey) &&
                (handler == nil && !strict || handler != nil && self.dynamicType.compareBlocks(definition.handler, handler))
        })
    }

    // MARK: -

    override public init() {
        super.init()
        HotkeyCenter.instance.register(self)
    }
}

// MARK: -

extension HotkeyObserver
{
    public enum Error: ErrorType
    {
        case UppInstallFailed
        case UppRemoveFail
    }
}