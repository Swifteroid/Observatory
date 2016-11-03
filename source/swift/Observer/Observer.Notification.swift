import Foundation

/*
Notification observer provides an interface for registering and managing multiple notification handlers. When we register  
notification handler observer creates handler definition – it manages that specific notification-handler association. 
*/
public class NotificationObserver: Observer
{
    public typealias SELF = NotificationObserver
    public typealias HandlerBlock = (notification: NSNotification) -> ()
    public typealias ConventionHandlerBlock = @convention(block) (notification: NSNotification) -> ()

    override public var active: Bool {
        didSet {
            if self.active == oldValue {
                return
            } else if self.active {
                for definition: HandlerDefinition in self.definitions {
                    definition.activate(self.center)
                }
            } else {
                for definition: HandlerDefinition in self.definitions {
                    definition.deactivate()
                }
            }
        }
    }

    public let center: NSNotificationCenter

    /*
    Registered notification handler definitions.
    */
    internal var definitions: [HandlerDefinition] = []

    public init(center: NSNotificationCenter? = nil) {
        self.center = center ?? NSNotificationCenter.defaultCenter()
    }

    public convenience init(active: Bool, center: NSNotificationCenter? = nil) {
        self.init(center: center)
        self.active = active
    }

    /*
    Create new observation for the specified notification name and observable target.
    */
    func add(name: String, observable: AnyObject?, queue: NSOperationQueue?, handler: Any) throws -> SELF {
        var notificationHandler: Any

        if handler is Block {
            notificationHandler = { (notification: NSNotification) in (handler as! Block)() }
        } else if handler is ConventionBlock {
            notificationHandler = { (notification: NSNotification) in (handler as! ConventionBlock)() }
        } else if handler is HandlerBlock || handler is ConventionHandlerBlock {
            notificationHandler = handler
        } else {
            throw Error.UnrecognisedHandlerSignature
        }

        let definition: HandlerDefinition = HandlerDefinition(name: name, observable: observable, queue: queue, handler: (original: handler, normalised: notificationHandler))

        // Make sure we're not adding the same definition twice and register observer with notification center
        // if observer is active. Comparison of handlers would only work with @convention(block) signatures.

        if self.definitions.contains(definition) {
            return self
        }

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
            if let definition: HandlerDefinition = self.definitions[i] where (name == nil && !strict || definition.name == name) && (observable == nil && !strict || definition.observable === observable) && (queue == nil && !strict || definition.queue === queue) && (handler == nil && !strict || handler != nil && SELF.compareBlocks(definition.handler.original, handler)) {
                self.definitions.removeAtIndex(i)

                // Don't do `i -= 1` – this is not a for loop, these good days are in the past now…

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

    override public class func compareBlocks(block1: Any, _ block2: Any) -> Bool {
        if block1 is ConventionHandlerBlock && block2 is ConventionHandlerBlock && unsafeBitCast(block1 as! ConventionHandlerBlock, AnyObject.self) === unsafeBitCast(block2 as! ConventionHandlerBlock, AnyObject.self) {
            return true
        }

        return Observer.compareBlocks(block1, block2)
    }
}

extension NotificationObserver
{
    public class func weakenHandler<T:AnyObject>(instance: T, method: (T) -> HandlerBlock) -> HandlerBlock {
        return { [unowned instance] (notification: NSNotification) in method(instance)(notification: notification) }
    }
}

extension NotificationObserver
{

    /*
    Handler definition provides a way of storing and managing individual notification handlers, most properties
    represent arguments passed into `NSNotificationCenter.addObserverForName` method.
    */
    public class HandlerDefinition: Equatable
    {
        public typealias SELF = HandlerDefinition
        public typealias Handler = (original: Any, normalised: Any)

        public private(set) var name: String
        public private(set) var observable: AnyObject?
        public private(set) var queue: NSOperationQueue?
        public private(set) var handler: Handler

        public private(set) var observer: AnyObject?
        public private(set) var center: NSNotificationCenter?

        init(name: String, observable: AnyObject?, queue: NSOperationQueue?, handler: Handler) {
            self.name = name
            self.observable = observable
            self.queue = queue
            self.handler = handler
        }

        /*
        Activates definition by attaching handler to specified notification center.  
        */
        public func activate(center: NSNotificationCenter) -> SELF {
            if self.observer == nil {
                self.observer = center.addObserverForName(self.name, object: self.observable, queue: self.queue, usingBlock: self.handler.normalised as! HandlerBlock)
                self.center = center
            }
            return self
        }

        public func deactivate() -> SELF {
            if let observer: AnyObject = self.observer, center: NSNotificationCenter = self.center {
                center.removeObserver(observer)
                self.observer = nil
                self.center = nil
            }
            return self
        }

        deinit {
            self.deactivate()
        }
    }
}

public func ==(left: NotificationObserver.HandlerDefinition, right: NotificationObserver.HandlerDefinition) -> Bool {
    return left.name == right.name &&
        left.observable === right.observable &&
        left.queue == right.queue &&
        NotificationObserver.compareBlocks(left.handler.original, right.handler.original)
}

public protocol NotificationObserverHandler: ObserverHandler
{
    func weakenHandler(method: (Self) -> NotificationObserver.HandlerBlock) -> NotificationObserver.HandlerBlock
}

extension NotificationObserverHandler
{
    public func weakenHandler(method: (Self) -> NotificationObserver.HandlerBlock) -> NotificationObserver.HandlerBlock {
        return NotificationObserver.weakenHandler(self, method: method)
    }
}