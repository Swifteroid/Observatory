import Foundation

/*
Notification observer provides an interface for registering and managing multiple notification handlers. When we register
notification handler observer creates handler definition – it manages that specific notification-handler association.
*/
public class NotificationObserver: Observer
{
    public typealias SELF = NotificationObserver

    // MARK: -

    override public var active: Bool {
        didSet {
            if self.active == oldValue {
                return
            } else if self.active {
                for definition: NotificationObserverHandlerDefinition in self.definitions {
                    definition.activate(self.center)
                }
            } else {
                for definition: NotificationObserverHandlerDefinition in self.definitions {
                    definition.deactivate()
                }
            }
        }
    }

    public let center: NSNotificationCenter

    /*
    Registered notification handler definitions.
    */
    public internal(set) var definitions: [NotificationObserverHandlerDefinition] = []

    // MARK: -

    public init(center: NSNotificationCenter? = nil) {
        self.center = center ?? NSNotificationCenter.defaultCenter()
    }

    public convenience init(active: Bool, center: NSNotificationCenter? = nil) {
        self.init(center: center)
        self.active = active
    }

    // MARK: -

    /*
    Create new observation for the specified notification name and observable target.
    */
    public func add(name: String, observable: AnyObject?, queue: NSOperationQueue?, handler: Any) throws -> SELF {
        let factory: NotificationObserverHandlerDefinitionFactory = NotificationObserverHandlerDefinitionFactory(name: name, observable: observable, queue: queue, handler: handler)
        let definition: NotificationObserverHandlerDefinition = try! factory.construct()

        guard !self.definitions.contains(definition) else { return self }
        self.definitions.append(self.active ? definition.activate(center) : definition)

        return self
    }

    public func add(name: String, observable: AnyObject?, handler: Any) throws -> SELF {
        return try self.add(name, observable: observable, queue: nil, handler: handler)
    }

    public func add(names: [String], observable: AnyObject?, queue: NSOperationQueue?, handler: Any) throws -> SELF {
        for name in names {
            try self.add(name, observable: observable, queue: queue, handler: handler)
        }
        return self
    }

    public func add(names: [String], observable: AnyObject?, handler: Any) throws -> SELF {
        for name in names {
            try self.add(name, observable: observable, handler: handler)
        }
        return self
    }

    /*
    When removing in non-strict mode the method treat nil values as matching.
    */
    public func remove(name: String?, observable: AnyObject?, queue: NSOperationQueue?, handler: Any?, strict: Bool) -> Self {
        var i: Int = 0
        var n: Int = self.definitions.count

        while i < n {
            if let definition: NotificationObserverHandlerDefinition = self.definitions[i] where (name == nil && !strict || definition.name == name) && (observable == nil && !strict || definition.observable === observable) && (queue == nil && !strict || definition.queue === queue) && (handler == nil && !strict || handler != nil && SELF.compareBlocks(definition.handler.original, handler)) {
                self.definitions.removeAtIndex(i)
                n -= 1
            } else {
                i += 1
            }
        }

        return self
    }

    public func remove(name: String?, observable: AnyObject?, queue: NSOperationQueue?, handler: Any?) -> SELF {
        return self.remove(name, observable: observable, queue: queue, handler: handler, strict: false)
    }

    public func remove(name: String?, observable: AnyObject?, handler: Any?) -> SELF {
        return self.remove(name, observable: observable, queue: nil, handler: handler, strict: false)
    }

    public func remove(name: String?, observable: AnyObject?) -> SELF {
        return self.remove(name, observable: observable, queue: nil, handler: nil, strict: false)
    }

    public func remove(name: String) -> SELF {
        return self.remove(name, observable: nil, queue: nil, handler: nil, strict: false)
    }

    public func remove(observable: AnyObject) -> SELF {
        return self.remove(nil, observable: observable, queue: nil, handler: nil, strict: false)
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