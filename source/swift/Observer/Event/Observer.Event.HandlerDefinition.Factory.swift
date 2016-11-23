import Foundation

open class EventObserverHandlerDefinitionFactory
{
    open var mask: NSEventMask
    open var global: Bool
    open var local: Bool
    open var handler: Any

    // MARK: -

    public init(mask: NSEventMask, global: Bool, local: Bool, handler: Any) {
        self.mask = mask
        self.global = global
        self.local = local
        self.handler = handler
    }

    // MARK: -

    open func construct() throws -> EventObserverHandlerDefinition {
        if !self.global && !self.local {
            throw Error.unspecifiedContext
        }

        var definition: EventObserverHandlerDefinition!
        let originalHandler: Any = self.handler
        var localHandler: Any?
        var globalHandler: Any?

        // Verify that we can work with the given handler, by default both handlers receive event object, local handlers
        // must also return event in case it should continue dispatching. We may not always need or want to implement any
        // of these, therefore if we normalise all recognised relaxed signatures here before storing them.

        // @formatter:off
        if originalHandler is ObserverHandler {
            globalHandler = self.global ? { (event: NSEvent) in (originalHandler as! ObserverHandler)() } : nil
            localHandler = self.local ? { (event: NSEvent) -> NSEvent? in (originalHandler as! ObserverHandler)(); return event } : nil
        } else if originalHandler is ObserverConventionHandler {
            globalHandler = self.global ? { (event: NSEvent) in (originalHandler as! ObserverConventionHandler)() } : nil
            localHandler = self.local ? { (event: NSEvent) -> NSEvent? in (originalHandler as! ObserverConventionHandler)(); return event } : nil
        } else if originalHandler is EventObserverHandler.Local {
            globalHandler = self.global ? { (event: NSEvent) in (originalHandler as! EventObserverHandler.Local)(event) } : nil
            localHandler = self.local ? originalHandler as? EventObserverHandler.Local : nil
        } else if originalHandler is EventObserverConventionHandler.Local {
            globalHandler = self.global ? { (event: NSEvent) in (originalHandler as! EventObserverConventionHandler.Local)(event) } : nil
            localHandler = self.local ? originalHandler as? EventObserverConventionHandler.Local : nil
        } else if originalHandler is EventObserverHandler.Global {
            globalHandler = self.global ? originalHandler as? EventObserverHandler.Global : nil
            localHandler = self.local ? { (event: NSEvent) -> NSEvent? in (originalHandler as! EventObserverHandler.Global)(event); return event } : nil
        } else if originalHandler is EventObserverConventionHandler.Global {
            globalHandler = self.global ? originalHandler as? EventObserverConventionHandler.Global : nil
            localHandler = self.local ? { (event: NSEvent) -> NSEvent? in (originalHandler as! EventObserverConventionHandler.Global)(event); return event } : nil
        }
        // @formatter:on

        if self.global && globalHandler == nil || self.local && localHandler == nil {
            throw Observer.Error.unrecognisedHandlerSignature
        }

        definition = EventObserverHandlerDefinition(mask: self.mask, handler: (original: originalHandler, global: globalHandler, local: localHandler))
        return definition
    }
}

// MARK: -

extension EventObserverHandlerDefinitionFactory
{
    public enum Error: Swift.Error
    {
        /*
        Event context, global or local, was not specified.
        */
        case unspecifiedContext
    }
}