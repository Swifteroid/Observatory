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

private func getEventHotKey(event: EventRef) -> EventHotKeyID {
    let pointer: UnsafeMutablePointer<EventHotKeyID> = UnsafeMutablePointer.alloc(1)
    GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, sizeof(EventHotKeyID), nil, pointer)
    return pointer.memory
}

// MARK: -

public class HotKeyObserver: Observer
{
    private typealias EventHandler = EventHandlerUPP
    private typealias EventHandlerPointer = EventHandlerRef
    private typealias EventHotKeyHandler = (EventHotKeyID) -> ()
    private typealias EventHotKeyHandlerPointer = UnsafeMutablePointer<EventHotKeyHandler>

    private var eventHandlerPointer: EventHandlerPointer!
    private var eventHotKeyHandlerPointer: EventHotKeyHandlerPointer!

    // MARK: -

    public internal(set) var definitions: [HotKeyObserverHandlerDefinition] = []

    // MARK: -

    override internal func activate() {

        // Before we can register any hot keys we must register an event handler with carbon framework.

        let (eventHandler, eventHotKeyHandler) = try! self.constructEventHandler()

        self.eventHandlerPointer = eventHandler
        self.eventHotKeyHandlerPointer = eventHotKeyHandler

        for definition in self.definitions {
            try! definition.activate(eventHandler)
        }
    }

    override internal func deactivate() {

        // Deactivation goes in reverse, first deactivate definitions then event handler.

        for definition in self.definitions {
            try! definition.deactivate()
        }

        try! self.destructEventHandler(self.eventHandlerPointer, eventHotKeyHandler: self.eventHotKeyHandlerPointer)

        self.eventHandlerPointer = nil
        self.eventHotKeyHandlerPointer = nil
    }

    // MARK: -

    private func constructEventHandler() throws -> (EventHandlerPointer, EventHotKeyHandlerPointer) {
        var eventType: EventTypeSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let eventHandler: EventHandler
        var eventHandlerPointer: EventHandlerPointer = nil
        let eventHotKeyHandlerPointer: UnsafeMutablePointer<EventHotKeyHandler> = UnsafeMutablePointer.alloc(1)

        eventHandler = { (nextHandler: EventHandlerCallRef, event: EventRef, pointer: UnsafeMutablePointer<Void>) -> OSStatus in
            UnsafeMutablePointer<EventHotKeyHandler>(pointer).memory(getEventHotKey(event))
            return CallNextEventHandler(nextHandler, event)
        }

        eventHotKeyHandlerPointer.initialize({ [unowned self] (identifier: EventHotKeyID) in
            for definition in self.definitions {
                if definition.hotKeyIdentifier == identifier {
                    (definition.handler as! ObserverHandler)()
                    break
                }
            }
        })

        // Create universal procedure pointer, so it can be passed to C.

        guard let status: OSStatus = InstallEventHandler(GetApplicationEventTarget(), eventHandler, 1, &eventType, eventHotKeyHandlerPointer, &eventHandlerPointer) where status == Darwin.noErr else {
            throw Error.UppInstallFailed
        }

        return (eventHandlerPointer, eventHotKeyHandlerPointer)
    }

    private func destructEventHandler(eventHandler: EventHandlerPointer, eventHotKeyHandler: EventHotKeyHandlerPointer) throws {
        guard let status: OSStatus = RemoveEventHandler(eventHandler) where status == Darwin.noErr else {
            throw Error.UppRemoveFail
        }

        eventHotKeyHandler.dealloc(1)
    }

    // MARK: -

    public func add(key: UInt32, modifier: UInt32, handler: Any) throws -> HotKeyObserver {
        let factory: HotKeyObserverHandlerDefinitionFactory = HotKeyObserverHandlerDefinitionFactory(key: key, modifier: modifier, handler: handler)
        let definition: HotKeyObserverHandlerDefinition = try! factory.construct()

        guard !self.definitions.contains(definition) else { return self }
        self.definitions.append(self.active ? (try! definition.activate(self.eventHandlerPointer)) : definition)

        return self
    }

    public func remove(key: UInt32, modifier: UInt32, handler: Any?, strict: Bool) -> Self {
        var i: Int = 0
        var n: Int = self.definitions.count

        while i < n {
            if let definition: HotKeyObserverHandlerDefinition = self.definitions[i] where (definition.key == key) && (definition.modifier == modifier) && (handler == nil && !strict || handler != nil && self.dynamicType.compareBlocks(definition.handler, handler)) {
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

// MARK: -

extension HotKeyObserver
{
    public enum Error: ErrorType
    {
        case UppInstallFailed
        case UppRemoveFail
    }
}