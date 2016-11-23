import Foundation

/*
Event observer provides a flexible interface for registering and managing multiple event handlers in, both, global
and local contexts.
*/
open class EventObserver: Observer
{
    override open var active: Bool {
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

    open internal(set) var definitions: [EventObserverHandlerDefinition] = []

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

    @discardableResult open func add(mask: NSEventMask, global: Bool, local: Bool, handler: Any) throws -> Self {
        let factory: EventObserverHandlerDefinitionFactory = EventObserverHandlerDefinitionFactory(mask: mask, global: global, local: local, handler: handler)
        let definition: EventObserverHandlerDefinition = try! factory.construct()

        guard !self.definitions.contains(definition) else { return self }
        self.definitions.append(self.active ? definition.activate() : definition)

        return self
    }

    @discardableResult open func add(mask: NSEventMask, handler: Any) throws -> Self {
        return try self.add(mask: mask, global: true, local: true, handler: handler)
    }

    @discardableResult open func remove(mask: NSEventMask, handler: Any?, strict: Bool) -> Self {
        for (index, _) in self.filter(mask: mask, handler: handler, strict: strict).reversed() {
            self.definitions.remove(at: index)
        }

        return self
    }

    @discardableResult open func remove(mask: NSEventMask, handler: Any?) -> Self {
        return self.remove(mask: mask, handler: handler, strict: false)
    }

    @discardableResult open func remove(mask: NSEventMask) -> Self {
        return self.remove(mask: mask, handler: nil, strict: false)
    }

    // MARK: -

    private func filter(mask: NSEventMask, handler: Any?, strict: Bool) -> [(offset: Int, element: EventObserverHandlerDefinition)] {
        return self.definitions.enumerated().filter({ (_: Int, definition: EventObserverHandlerDefinition) in
            return true &&
                (mask == definition.mask) &&
                (handler == nil && !strict || handler != nil && type(of: self).compareBlocks(definition.handler.original, handler!))
        })
    }

    // MARK: -

    override open class func compareBlocks(_ lhs: Any, _ rhs: Any) -> Bool {
        if lhs is EventObserverConventionHandler.Global && rhs is EventObserverConventionHandler.Global {
            return unsafeBitCast(lhs as! EventObserverConventionHandler.Global, to: AnyObject.self) === unsafeBitCast(rhs as! EventObserverConventionHandler.Global, to: AnyObject.self)
        } else if lhs is EventObserverConventionHandler.Local && rhs is EventObserverConventionHandler.Local {
            return unsafeBitCast(lhs as! EventObserverConventionHandler.Local, to: AnyObject.self) === unsafeBitCast(rhs as! EventObserverConventionHandler.Local, to: AnyObject.self)
        } else {
            return Observer.compareBlocks(lhs, rhs)
        }
    }
}