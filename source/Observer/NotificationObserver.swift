import Foundation

/*
Notification observer provides an interface for registering and managing multiple notification handlers. When we register  
notification handler observer creates handler definition – it manages that specific notification-handler association. 
*/
public class NotificationObserver: Observer
{
    public typealias HandlerBlock = (Notification) -> ()
    public typealias ConventionHandlerBlock = @convention(block) (Notification) -> ()

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

    public let center: NotificationCenter

    /*
    Registered notification handler definitions.
    */
    internal var definitions: [HandlerDefinition] = []

    public init(center: NotificationCenter? = nil) {
        self.center = center ?? NotificationCenter.default
    }

    public convenience init(active: Bool, center: NotificationCenter? = nil) {
        self.init(center: center)
        self.active = active
    }

    /*
    Create new observation for the specified notification name and observable target.
    */
    @discardableResult func add(name: String, observable: AnyObject?, queue: NSOperationQueue?, handler: Any) throws -> Self {
        var notificationHandler: Any

        if handler is Block {
            notificationHandler = { (notification: Notification) in (handler as! Block)() }
        } else if handler is ConventionBlock {
            notificationHandler = { (notification: Notification) in (handler as! ConventionBlock)() }
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

    @discardableResult public func add(name: String, observable: AnyObject?, handler: Any) throws -> Self {
        return try self.add(name, observable: observable, queue: nil, handler: handler)
    }

    @discardableResult public func add(names: [String], observable: AnyObject?, queue: NSOperationQueue?, handler: Any) throws -> Self {
        for name in names {
            try self.add(name, observable: observable, queue: queue, handler: handler)
        }
        return self
    }

    @discardableResult public func add(names: [String], observable: AnyObject?, handler: Any) throws -> Self {
        for name in names {
            try self.add(name, observable: observable, handler: handler)
        }
        return self
    }

    /*
    When removing in non-strict mode the method treat nil values as matching.
    */
    @discardableResult public func remove(name: String?, observable: AnyObject?, queue: NSOperationQueue?, handler: Any?, strict: Bool) -> Self {
        var i: Int = 0
        var n: Int = self.definitions.count

        while i < n {
            if let definition: HandlerDefinition = self.definitions[i], (name == nil && !strict || definition.name == name) && (observable == nil && !strict || definition.observable === observable) && (queue == nil && !strict || definition.queue === queue) && (handler == nil && !strict || handler != nil && Self.compareBlocks(definition.handler.original, handler)) {
                self.definitions.removeAtIndex(i)

                // Don't do `i -= 1` – this is not a for loop, these good days are in the past now…

                n -= 1
            } else {
                i += 1
            }
        }

        return self
    }

    @discardableResult public func remove(name: String?, observable: AnyObject?, queue: NSOperationQueue?, handler: Any?) -> Self {
        return self.remove(name, observable: observable, queue: queue, handler: handler, strict: false)
    }

    @discardableResult public func remove(name: String?, observable: AnyObject?, handler: Any?) -> Self {
        return self.remove(name, observable: observable, queue: nil, handler: handler, strict: false)
    }

    @discardableResult public func remove(name: String?, observable: AnyObject?) -> Self {
        return self.remove(name, observable: observable, queue: nil, handler: nil, strict: false)
    }

    @discardableResult public func remove(name: String) -> Self {
        return self.remove(name, observable: nil, queue: nil, handler: nil, strict: false)
    }

    @discardableResult public func remove(observable: AnyObject) -> Self {
        return self.remove(nil, observable: observable, queue: nil, handler: nil, strict: false)
    }

    override open class func compareBlocks(_ lhs: Any, _ rhs: Any) -> Bool {
        if lhs is ConventionHandlerBlock && rhs is ConventionHandlerBlock && unsafeBitCast(lhs as! ConventionHandlerBlock, AnyObject.self) === unsafeBitCast(rhs as! ConventionHandlerBlock, AnyObject.self) {
            return true
        }

        return super.compareBlocks(lhs, rhs)
    }
}

extension NotificationObserver
{

    /*
    Handler definition provides a way of storing and managing individual notification handlers, most properties
    represent arguments passed into `NotificationCenter.addObserverForName` method.
    */
    public class HandlerDefinition: Equatable
    {
        public typealias Handler = (original: Any, normalised: Any)

        public private(set) var name: String
        public private(set) var observable: AnyObject?
        public private(set) var queue: NSOperationQueue?
        public private(set) var handler: Handler

        public private(set) var observer: AnyObject?
        public private(set) var center: NotificationCenter?

        init(name: String, observable: AnyObject?, queue: NSOperationQueue?, handler: Handler) {
            self.name = name
            self.observable = observable
            self.queue = queue
            self.handler = handler
        }

        /*
        Activates definition by attaching handler to specified notification center.  
        */
        @discardableResult public func activate(center: NotificationCenter) -> Self {
            if self.observer == nil {
                self.observer = center.addObserverForName(self.name, object: self.observable, queue: self.queue, usingBlock: self.handler.normalised as! HandlerBlock)
                self.center = center
            }
            return self
        }

        @discardableResult public func deactivate() -> Self {
            if let observer: AnyObject = self.observer, let center: NotificationCenter = self.center {
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

public func ==(lhs: NotificationObserver.HandlerDefinition, rhs: NotificationObserver.HandlerDefinition) -> Bool {
    return lhs.name == rhs.name &&
        lhs.observable === rhs.observable &&
        lhs.queue == rhs.queue &&
        NotificationObserver.compareBlocks(lhs.handler.original, rhs.handler.original)
}