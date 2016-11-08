import Foundation

/*
Notification observer provides an interface for registering and managing multiple notification handlers. When we register
notification handler observer creates handler definition – it manages that specific notification-handler association.
*/
public class NotificationObserver: Observer
{
    public typealias SELF = NotificationObserver

    // MARK: -

    public var center: NSNotificationCenter?

    public private(set) var definitions: [NotificationObserverHandlerDefinition] = []

    // MARK: -

    override internal func activate() {
        for definition: NotificationObserverHandlerDefinition in self.definitions {
            definition.activate(self.center ?? NSNotificationCenter.defaultCenter())
        }
    }

    override internal func deactivate() {
        for definition: NotificationObserverHandlerDefinition in self.definitions {
            definition.deactivate()
        }
    }

    // MARK: -

    convenience init(center: NSNotificationCenter) {
        self.init()
        self.center = center
    }

    public convenience init(active: Bool, center: NSNotificationCenter) {
        self.init(active: active)
        self.center = center
    }

    // MARK: -

    public func add(name: String, observable: AnyObject?, queue: NSOperationQueue?, handler: Any) throws -> SELF {
        let factory: NotificationObserverHandlerDefinitionFactory = NotificationObserverHandlerDefinitionFactory(name: name, observable: observable, queue: queue, handler: handler)
        let definition: NotificationObserverHandlerDefinition = try! factory.construct()

        guard !self.definitions.contains(definition) else { return self }
        self.definitions.append(self.active ? definition.activate(center ?? NSNotificationCenter.defaultCenter()) : definition)

        return self
    }

    public func add(name: String, observable: AnyObject?, handler: Any) throws -> SELF {
        return try self.add(name, observable: observable, queue: nil, handler: handler)
    }

    public func add(names: [String], observable: AnyObject?, queue: NSOperationQueue?, handler: Any) throws -> Self {
        for name in names {
            try self.add(name, observable: observable, queue: queue, handler: handler)
        }

        return self
    }

    public func add(names: [String], observable: AnyObject?, handler: Any) throws -> Self {
        for name in names {
            try self.add(name, observable: observable, handler: handler)
        }

        return self
    }

    public func remove(name: String?, observable: AnyObject?, queue: NSOperationQueue?, handler: Any?, strict: Bool) -> Self {
        for (index, _) in self.filter(name, observable: observable, queue: queue, handler: handler, strict: strict).reverse() {
            self.definitions.removeAtIndex(index)
        }

        return self
    }

    public func remove(name: String?, observable: AnyObject?, queue: NSOperationQueue?, handler: Any?) -> Self {
        return self.remove(name, observable: observable, queue: queue, handler: handler, strict: false)
    }

    public func remove(name: String?, observable: AnyObject?, handler: Any?) -> Self {
        return self.remove(name, observable: observable, queue: nil, handler: handler, strict: false)
    }

    public func remove(name: String?, observable: AnyObject?) -> Self {
        return self.remove(name, observable: observable, queue: nil, handler: nil, strict: false)
    }

    public func remove(name: String) -> Self {
        return self.remove(name, observable: nil, queue: nil, handler: nil, strict: false)
    }

    public func remove(observable: AnyObject) -> Self {
        return self.remove(nil, observable: observable, queue: nil, handler: nil, strict: false)
    }

    // MARK: -

    /*
    Nil values are treated as matching when filtering in non-strict mode.
    */
    private func filter(name: String?, observable: AnyObject?, queue: NSOperationQueue?, handler: Any?, strict: Bool) -> [(index: Int, element: NotificationObserverHandlerDefinition)] {
        return self.definitions.enumerate().filter({ (_: Int, definition: NotificationObserverHandlerDefinition) in
            return true &&
                (name == nil && !strict || definition.name == name) &&
                (observable == nil && !strict || definition.observable === observable) &&
                (queue == nil && !strict || definition.queue === queue) &&
                (handler == nil && !strict || handler != nil && self.dynamicType.compareBlocks(definition.handler.original, handler))
        })
    }

    // MARK: -

    override public class func compareBlocks(lhs: Any, _ rhs: Any) -> Bool {
        if lhs is NotificationObserverConventionHandler && rhs is NotificationObserverConventionHandler {
            return unsafeBitCast(lhs as! NotificationObserverConventionHandler, AnyObject.self) === unsafeBitCast(rhs as! NotificationObserverConventionHandler, AnyObject.self)
        } else {
            return Observer.compareBlocks(lhs, rhs)
        }
    }
}

extension NotificationObserver
{
    public class func weakenHandler<T:AnyObject>(instance: T, method: (T) -> NotificationObserverHandler) -> NotificationObserverHandler {
        return { [unowned instance] (notification: NSNotification) in method(instance)(notification: notification) }
    }
}

public protocol NotificationObserverHandlerProtocol: ObserverHandlerProtocol
{
    func weakenHandler(method: (Self) -> NotificationObserverHandler) -> NotificationObserverHandler
}

extension NotificationObserverHandlerProtocol
{
    public func weakenHandler(method: (Self) -> NotificationObserverHandler) -> NotificationObserverHandler {
        return NotificationObserver.weakenHandler(self, method: method)
    }
}