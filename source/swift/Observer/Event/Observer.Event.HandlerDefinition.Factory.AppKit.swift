import Foundation

open class AppKitEventObserverHandlerDefinitionFactory
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

    open func construct() throws -> AppKitEventObserverHandlerDefinition {
        if !self.global && !self.local {
            throw Error.unspecifiedContext
        }

        var definition: AppKitEventObserverHandlerDefinition!
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
        } else if originalHandler is AppKitEventObserverHandler.Local {
            globalHandler = self.global ? { (event: NSEvent) in (originalHandler as! AppKitEventObserverHandler.Local)(event) } : nil
            localHandler = self.local ? originalHandler : nil
        } else if originalHandler is AppKitEventObserverConventionHandler.Local {
            globalHandler = self.global ? { (event: NSEvent) in (originalHandler as! AppKitEventObserverConventionHandler.Local)(event) } : nil
            localHandler = self.local ? originalHandler : nil
        } else if originalHandler is AppKitEventObserverHandler.Global {
            globalHandler = self.global ? originalHandler : nil
            localHandler = self.local ? { (event: NSEvent) -> NSEvent? in (originalHandler as! AppKitEventObserverHandler.Global)(event); return event } : nil
        } else if originalHandler is AppKitEventObserverConventionHandler.Global {
            globalHandler = self.global ? originalHandler : nil
            localHandler = self.local ? { (event: NSEvent) -> NSEvent? in (originalHandler as! AppKitEventObserverConventionHandler.Global)(event); return event } : nil
        }
        // @formatter:on

        if self.global && globalHandler == nil || self.local && localHandler == nil {
            throw Observer.Error.unrecognisedHandlerSignature
        }

        definition = AppKitEventObserverHandlerDefinition(mask: self.mask, handler: (original: originalHandler, global: globalHandler, local: localHandler))
        return definition
    }
}

// MARK: -

extension AppKitEventObserverHandlerDefinitionFactory
{
    public enum Error: Swift.Error
    {
        /*
        Event context, global or local, was not specified.
        */
        case unspecifiedContext
    }
}