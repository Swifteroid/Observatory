import Foundation

/*
Notification observer provides an interface for registering and managing multiple notification handlers. When we register
notification handler observer creates handler definition – it manages that specific notification-handler association.
*/
open class NotificationObserver: Observer
{
    open var center: NotificationCenter?

    open private(set) var definitions: [NotificationObserverHandlerDefinition] = []

    // MARK: -

    override internal func activate() {
        for definition: NotificationObserverHandlerDefinition in self.definitions {
            definition.activate(center: self.center ?? NotificationCenter.default)
        }
    }

    override internal func deactivate() {
        for definition: NotificationObserverHandlerDefinition in self.definitions {
            definition.deactivate()
        }
    }

    // MARK: -

    convenience init(center: NotificationCenter) {
        self.init()
        self.center = center
    }

    public convenience init(active: Bool, center: NotificationCenter) {
        self.init(active: active)
        self.center = center
    }

    // MARK: -

    @discardableResult open func add(name: Notification.Name, observable: AnyObject?, queue: OperationQueue?, handler: Any) throws -> Self {
        let factory: NotificationObserverHandlerDefinitionFactory = NotificationObserverHandlerDefinitionFactory(name: name, observable: observable, queue: queue, handler: handler)
        let definition: NotificationObserverHandlerDefinition = try! factory.construct()

        guard !self.definitions.contains(definition) else { return self }
        self.definitions.append(self.active ? definition.activate(center: center ?? NotificationCenter.default) : definition)

        return self
    }

    @discardableResult open func add(name: Notification.Name, observable: AnyObject?, handler: Any) throws -> Self {
        return try self.add(name: name, observable: observable, queue: nil, handler: handler)
    }

    @discardableResult open func add(names: [Notification.Name], observable: AnyObject?, queue: OperationQueue?, handler: Any) throws -> Self {
        for name in names {
            try self.add(name: name, observable: observable, queue: queue, handler: handler)
        }

        return self
    }

    @discardableResult open func add(names: [Notification.Name], observable: AnyObject?, handler: Any) throws -> Self {
        for name in names {
            try self.add(name: name, observable: observable, handler: handler)
        }

        return self
    }

    @discardableResult open func remove(name: Notification.Name?, observable: AnyObject?, queue: OperationQueue?, handler: Any?, strict: Bool) -> Self {
        for (index, _) in self.filter(name: name, observable: observable, queue: queue, handler: handler, strict: strict).reversed() {
            self.definitions.remove(at: index)
        }

        return self
    }

    @discardableResult open func remove(name: Notification.Name?, observable: AnyObject?, queue: OperationQueue?, handler: Any?) -> Self {
        return self.remove(name: name, observable: observable, queue: queue, handler: handler, strict: false)
    }

    @discardableResult open func remove(name: Notification.Name?, observable: AnyObject?, handler: Any?) -> Self {
        return self.remove(name: name, observable: observable, queue: nil, handler: handler, strict: false)
    }

    @discardableResult open func remove(name: Notification.Name?, observable: AnyObject?) -> Self {
        return self.remove(name: name, observable: observable, queue: nil, handler: nil, strict: false)
    }

    @discardableResult open func remove(name: Notification.Name) -> Self {
        return self.remove(name: name, observable: nil, queue: nil, handler: nil, strict: false)
    }

    @discardableResult open func remove(observable: AnyObject) -> Self {
        return self.remove(name: nil, observable: observable, queue: nil, handler: nil, strict: false)
    }

    // MARK: -

    /*
    Nil values are treated as matching when filtering in non-strict mode.
    */
    private func filter(name: Notification.Name?, observable: AnyObject?, queue: OperationQueue?, handler: Any?, strict: Bool) -> [(offset: Int, element: NotificationObserverHandlerDefinition)] {
        return self.definitions.enumerated().filter({ (_: Int, definition: NotificationObserverHandlerDefinition) in
            return true &&
                (name == nil && !strict || definition.name == name) &&
                (observable == nil && !strict || definition.observable === observable) &&
                (queue == nil && !strict || definition.queue == queue) &&
                (handler == nil && !strict || handler != nil && type(of: self).compareBlocks(definition.handler.original, handler!))
        })
    }

    // MARK: -

    override open class func compareBlocks(_ lhs: Any, _ rhs: Any) -> Bool {
        if lhs is NotificationObserverConventionHandler && rhs is NotificationObserverConventionHandler {
            return unsafeBitCast(lhs as! NotificationObserverConventionHandler, to: AnyObject.self) === unsafeBitCast(rhs as! NotificationObserverConventionHandler, to: AnyObject.self)
        } else {
            return Observer.compareBlocks(lhs, rhs)
        }
    }
}