import Foundation

open class CarbonEventObserverHandlerDefinitionFactory
{
    open let mask: CGEventMask
    open let location: CGEventTapLocation
    open let placement: CGEventTapPlacement
    open let options: CGEventTapOptions
    open var handler: Any

    // MARK: -

    public init(mask: CGEventMask, location: CGEventTapLocation, placement: CGEventTapPlacement, options: CGEventTapOptions, handler: Any) {
        self.mask = mask
        self.location = location
        self.placement = placement
        self.options = options
        self.handler = handler
    }

    // MARK: -

    open func construct() throws -> CarbonEventObserverHandlerDefinition {
        var definition: CarbonEventObserverHandlerDefinition!
        let originalHandler: Any = self.handler
        var normalHandler: Any?

        // Verify that we can work with the given handler, by default both handlers receive event object, local handlers
        // must also return event in case it should continue dispatching. We may not always need or want to implement any
        // of these, therefore if we normalise all recognised relaxed signatures here before storing them.

        // @formatter:off
        if originalHandler is ObserverHandler {
            normalHandler = { (event: CGEvent) -> CGEvent? in (originalHandler as! ObserverHandler)(); return event }
        } else if originalHandler is ObserverConventionHandler {
            normalHandler = { (event: CGEvent) -> CGEvent? in (originalHandler as! ObserverConventionHandler)(); return event }
        } else if originalHandler is CarbonEventObserverHandler.Local {
            normalHandler = originalHandler
        } else if originalHandler is CarbonEventObserverConventionHandler.Local {
            normalHandler = originalHandler
        } else if originalHandler is CarbonEventObserverHandler.Global {
            normalHandler = { (event: CGEvent) -> CGEvent? in (originalHandler as! CarbonEventObserverHandler.Global)(event); return event }
        } else if originalHandler is CarbonEventObserverConventionHandler.Global {
            normalHandler = { (event: CGEvent) -> CGEvent? in (originalHandler as! CarbonEventObserverConventionHandler.Global)(event); return event }
        }
        // @formatter:on

        if normalHandler == nil {
            throw Observer.Error.unrecognisedHandlerSignature
        }

        definition = CarbonEventObserverHandlerDefinition(mask: self.mask, location: self.location, placement: self.placement, options: self.options, handler: (original: originalHandler, normal: normalHandler!))
        return definition
    }
}