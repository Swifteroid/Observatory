import Foundation

/*
Event observer provides a flexible interface for registering and managing multiple event handlers in, both, global
and local contexts.
*/
public class EventObserver: Observer
{
    public typealias SELF = EventObserver
    public typealias GlobalEventHandler = (event: NSEvent) -> ()
    public typealias LocalEventHandler = (event: NSEvent) -> NSEvent?

    public typealias GlobalHandlerBlock = (event: NSEvent) -> Void
    public typealias GlobalConventionHandlerBlock = @convention(block) (event: NSEvent) -> Void

    public typealias LocalHandlerBlock = (event: NSEvent) -> NSEvent?
    public typealias LocalConventionHandlerBlock = @convention(block) (event: NSEvent) -> NSEvent?

    override public var active: Bool {
        didSet {
            if oldValue == self.active {
                return
            } else if self.active {
                for definition: HandlerDefinition in self.definitions {
                    definition.activate()
                }
            } else {
                for definition: HandlerDefinition in self.definitions {
                    definition.deactivate()
                }
            }
        }
    }

    internal var definitions: [HandlerDefinition] = []

    // MARK: -

    public convenience init(active: Bool) {
        self.init()
        self.active = active
    }

    // MARK: -

    /*
    Add new event observation and activate it if observer is active. 
    */
    public func add(mask: NSEventMask, global: Bool, local: Bool, handler: Any) throws -> SELF {
        if !global && !local {
            throw Error.UnspecifiedContext
        }

        var localEventHandler: Any?
        var globalEventHandler: Any?

        // Verify that we can work with the given handler, by default both handlers receive event object, local handlers 
        // must also return event in case it should continue dispatching. We may not always need or want to implement any 
        // of these, therefore if we normalise all recognised relaxed signatures here before storing them.

        // @formatter:off
        if handler is Block {
            globalEventHandler = global ? { (event: NSEvent) in (handler as! Block)() } : nil
            localEventHandler = local ? { (event: NSEvent) -> NSEvent? in (handler as! Block)(); return event } : nil
        } else if handler is ConventionBlock {
            globalEventHandler = global ? { (event: NSEvent) in (handler as! ConventionBlock)() } : nil
            localEventHandler = local ? { (event: NSEvent) -> NSEvent? in (handler as! ConventionBlock)(); return event } : nil
        } else if handler is LocalEventHandler {
            globalEventHandler = global ? { (event: NSEvent) in (handler as! LocalEventHandler)(event: event) } : nil
            localEventHandler = local ? handler as? LocalEventHandler : nil
        } else if handler is LocalConventionHandlerBlock {
            globalEventHandler = global ? { (event: NSEvent) in (handler as! LocalConventionHandlerBlock)(event: event) } : nil
            localEventHandler = local ? handler as? LocalConventionHandlerBlock : nil
        } else if handler is GlobalEventHandler {
            globalEventHandler = global ? handler as? GlobalEventHandler : nil
            localEventHandler = local ? { (event: NSEvent) -> NSEvent? in (handler as! GlobalEventHandler)(event: event); return event } : nil
        } else if handler is GlobalConventionHandlerBlock {
            globalEventHandler = global ? handler as? GlobalConventionHandlerBlock : nil
            localEventHandler = local ? { (event: NSEvent) -> NSEvent? in (handler as! GlobalConventionHandlerBlock)(event: event); return event } : nil
        }
        // @formatter:on

        if global && globalEventHandler == nil || local && localEventHandler == nil {
            throw Error.UnrecognisedHandlerSignature
        }

        let definition: HandlerDefinition = HandlerDefinition(mask: mask, handler: (original: handler, global: globalEventHandler, local: localEventHandler))

        // Make sure we're not adding the same definition twice and register observer with notification center
        // if observer is active. Comparison of handlers would only work with @convention(block) signatures.

        if self.definitions.contains(definition) {
            return self
        }

        self.definitions.append(self.active ? definition.activate() : definition)

        return self
    }

    public func add(mask: NSEventMask, handler: Any) throws -> SELF {
        return try self.add(mask, global: true, local: true, handler: handler)
    }

    public func remove(mask: NSEventMask, handler: Any? = nil) throws -> SELF {
        var i: Int = 0
        var n: Int = self.definitions.count

        while i < n {
            if let definition: HandlerDefinition = self.definitions[i] where mask == definition.mask && (handler == nil || SELF.compareBlocks(definition.handler.original, handler)) {
                self.definitions.removeAtIndex(i)

                // Don't do `i -= 1` – this is not a for loop, these good days are in the bast now…

                n -= 1
            } else {
                i += 1
            }
        }

        return self
    }

    // MARK: -

    override public class func compareBlocks(lhs: Any, _ rhs: Any) -> Bool {
        if lhs is GlobalConventionHandlerBlock && rhs is GlobalConventionHandlerBlock {
            return unsafeBitCast(lhs as! GlobalConventionHandlerBlock, AnyObject.self) === unsafeBitCast(rhs as! GlobalConventionHandlerBlock, AnyObject.self)
        } else if lhs is LocalConventionHandlerBlock && rhs is LocalConventionHandlerBlock {
            return unsafeBitCast(lhs as! LocalConventionHandlerBlock, AnyObject.self) === unsafeBitCast(rhs as! LocalConventionHandlerBlock, AnyObject.self)
        } else {
            return Observer.compareBlocks(lhs, rhs)
        }
    }
}

// MARK: weakening

extension EventObserver
{
    public class func weakenHandler<T:AnyObject>(instance: T, method: (T) -> GlobalEventHandler) -> GlobalEventHandler {
        return { [unowned instance] (event: NSEvent) in method(instance)(event: event) }
    }

    public class func weakenHandler<T:AnyObject>(instance: T, method: (T) -> LocalEventHandler) -> LocalEventHandler {
        return { [unowned instance] (event: NSEvent) in method(instance)(event: event) }
    }
}

extension EventObserver
{
    public enum Error: ErrorType
    {
        /*
        Event context, global or local, was not specified. 
        */
        case UnspecifiedContext
    }
}

public protocol EventObserverHandler: ObserverHandler
{
    func weakenHandler(method: (Self) -> EventObserver.GlobalEventHandler) -> EventObserver.GlobalEventHandler

    func weakenHandler(method: (Self) -> EventObserver.LocalEventHandler) -> EventObserver.LocalEventHandler
}

extension EventObserverHandler
{
    public func weakenHandler(method: (Self) -> EventObserver.GlobalEventHandler) -> EventObserver.GlobalEventHandler {
        return EventObserver.weakenHandler(self, method: method)
    }

    public func weakenHandler(method: (Self) -> EventObserver.LocalEventHandler) -> EventObserver.LocalEventHandler {
        return EventObserver.weakenHandler(self, method: method)
    }
}