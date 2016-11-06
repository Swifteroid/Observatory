import Foundation

public class EventObserverHandlerDefinitionFactory
{
    public var mask: NSEventMask
    public var global: Bool
    public var local: Bool
    public var handler: Any

    // MARK: -

    public init(mask: NSEventMask, global: Bool, local: Bool, handler: Any) {
        self.mask = mask
        self.global = global
        self.local = local
        self.handler = handler
    }

    // MARK: -

    public func construct() throws -> EventObserverHandlerDefinition {
        if !self.global && !self.local {
            throw Error.UnspecifiedContext
        }

        var definition: EventObserverHandlerDefinition!
        var localHandler: Any?
        var globalHandler: Any?

        // Verify that we can work with the given handler, by default both handlers receive event object, local handlers
        // must also return event in case it should continue dispatching. We may not always need or want to implement any
        // of these, therefore if we normalise all recognised relaxed signatures here before storing them.

        // @formatter:off
        if self.handler is ObserverHandler {
            globalHandler = self.global ? { (event: NSEvent) in (definition.handler.original as! ObserverHandler)() } : nil
            localHandler = self.local ? { (event: NSEvent) -> NSEvent? in (definition.handler.original as! ObserverHandler)(); return event } : nil
        } else if self.handler is ObserverConventionHandler {
            globalHandler = self.global ? { (event: NSEvent) in (definition.handler.original as! ObserverConventionHandler)() } : nil
            localHandler = self.local ? { (event: NSEvent) -> NSEvent? in (definition.handler.original as! ObserverConventionHandler)(); return event } : nil
        } else if self.handler is EventObserverHandler.Local {
            globalHandler = self.global ? { (event: NSEvent) in (definition.handler.original as! EventObserverHandler.Local)(event: event) } : nil
            localHandler = self.local ? self.handler as? EventObserverHandler.Local : nil
        } else if self.handler is EventObserverConventionHandler.Local {
            globalHandler = self.global ? { (event: NSEvent) in (definition.handler.original as! EventObserverConventionHandler.Local)(event: event) } : nil
            localHandler = self.local ? self.handler as? EventObserverConventionHandler.Local : nil
        } else if self.handler is EventObserverHandler.Global {
            globalHandler = self.global ? self.handler as? EventObserverHandler.Global : nil
            localHandler = self.local ? { (event: NSEvent) -> NSEvent? in (definition.handler.original as! EventObserverHandler.Global)(event: event); return event } : nil
        } else if self.handler is EventObserverConventionHandler.Global {
            globalHandler = self.global ? self.handler as? EventObserverConventionHandler.Global : nil
            localHandler = self.local ? { (event: NSEvent) -> NSEvent? in (definition.handler.original as! EventObserverConventionHandler.Global)(event: event); return event } : nil
        }
        // @formatter:on

        if self.global && globalHandler == nil || self.local && localHandler == nil {
            throw Observer.Error.UnrecognisedHandlerSignature
        }

        definition = EventObserverHandlerDefinition(mask: self.mask, handler: (original: self.handler, global: globalHandler, local: localHandler))
        return definition
    }
}

// MARK: -

extension EventObserverHandlerDefinitionFactory
{
    public enum Error: ErrorType
    {
        /*
        Event context, global or local, was not specified.
        */
        case UnspecifiedContext
    }
}