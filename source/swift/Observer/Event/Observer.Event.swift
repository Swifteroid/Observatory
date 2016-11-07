import Foundation

/*
Event observer provides a flexible interface for registering and managing multiple event handlers in, both, global
and local contexts.
*/
public class EventObserver: Observer
{
    public typealias SELF = EventObserver

    override public var active: Bool {
        didSet {
            if oldValue == self.active {
                return
            } else if self.active {
                for definition: EventObserverHandlerDefinition in self.definitions {
                    definition.activate()
                }
            } else {
                for definition: EventObserverHandlerDefinition in self.definitions {
                    definition.deactivate()
                }
            }
        }
    }

    public internal(set) var definitions: [EventObserverHandlerDefinition] = []

    // MARK: -

    override internal func activate() {
        for definition: EventObserverHandlerDefinition in self.definitions {
            definition.activate()
        }
    }

    override internal func deactivate() {
        for definition: EventObserverHandlerDefinition in self.definitions {
            definition.deactivate()
        }
    }

    // MARK: -

    public func add(mask: NSEventMask, global: Bool, local: Bool, handler: Any) throws -> SELF {
        let factory: EventObserverHandlerDefinitionFactory = EventObserverHandlerDefinitionFactory(mask: mask, global: global, local: local, handler: handler)
        let definition: EventObserverHandlerDefinition = try! factory.construct()

        guard !self.definitions.contains(definition) else { return self }
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
            if let definition: EventObserverHandlerDefinition = self.definitions[i] where mask == definition.mask && (handler == nil || SELF.compareBlocks(definition.handler.original, handler)) {
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
        if lhs is EventObserverConventionHandler.Global && rhs is EventObserverConventionHandler.Global {
            return unsafeBitCast(lhs as! EventObserverConventionHandler.Global, AnyObject.self) === unsafeBitCast(rhs as! EventObserverConventionHandler.Global, AnyObject.self)
        } else if lhs is EventObserverConventionHandler.Local && rhs is EventObserverConventionHandler.Local {
            return unsafeBitCast(lhs as! EventObserverConventionHandler.Local, AnyObject.self) === unsafeBitCast(rhs as! EventObserverConventionHandler.Local, AnyObject.self)
        } else {
            return Observer.compareBlocks(lhs, rhs)
        }
    }
}

// MARK: weakening

extension EventObserver
{
    public class func weakenHandler<T:AnyObject>(instance: T, method: (T) -> EventObserverHandler.Global) -> EventObserverHandler.Global {
        return { [unowned instance] (event: NSEvent) in method(instance)(event: event) }
    }

    public class func weakenHandler<T:AnyObject>(instance: T, method: (T) -> EventObserverHandler.Local) -> EventObserverHandler.Local {
        return { [unowned instance] (event: NSEvent) in method(instance)(event: event) }
    }
}

public protocol EventObserverHandlerProtocol: ObserverHandlerProtocol
{
    func weakenHandler(method: (Self) -> EventObserverHandler.Global) -> EventObserverHandler.Global

    func weakenHandler(method: (Self) -> EventObserverHandler.Local) -> EventObserverHandler.Local
}

extension EventObserverHandlerProtocol
{
    public func weakenHandler(method: (Self) -> EventObserverHandler.Global) -> EventObserverHandler.Global {
        return EventObserver.weakenHandler(self, method: method)
    }

    public func weakenHandler(method: (Self) -> EventObserverHandler.Local) -> EventObserverHandler.Local {
        return EventObserver.weakenHandler(self, method: method)
    }
}