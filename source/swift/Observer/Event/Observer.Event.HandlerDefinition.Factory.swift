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
            globalHandler = self.global ? { (event: NSEvent) in (originalHandler as! EventObserverHandler.Local)(event: event) } : nil
            localHandler = self.local ? originalHandler as? EventObserverHandler.Local : nil
        } else if originalHandler is EventObserverConventionHandler.Local {
            globalHandler = self.global ? { (event: NSEvent) in (originalHandler as! EventObserverConventionHandler.Local)(event: event) } : nil
            localHandler = self.local ? originalHandler as? EventObserverConventionHandler.Local : nil
        } else if originalHandler is EventObserverHandler.Global {
            globalHandler = self.global ? originalHandler as? EventObserverHandler.Global : nil
            localHandler = self.local ? { (event: NSEvent) -> NSEvent? in (originalHandler as! EventObserverHandler.Global)(event: event); return event } : nil
        } else if originalHandler is EventObserverConventionHandler.Global {
            globalHandler = self.global ? originalHandler as? EventObserverConventionHandler.Global : nil
            localHandler = self.local ? { (event: NSEvent) -> NSEvent? in (originalHandler as! EventObserverConventionHandler.Global)(event: event); return event } : nil
        }
        // @formatter:on

        if self.global && globalHandler == nil || self.local && localHandler == nil {
            throw Observer.Error.UnrecognisedHandlerSignature
        }

        definition = EventObserverHandlerDefinition(mask: self.mask, handler: (original: originalHandler, global: globalHandler, local: localHandler))
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