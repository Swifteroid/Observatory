import Foundation

public class NotificationObserverHandlerDefinition: Equatable
{
    public typealias SELF = NotificationObserverHandlerDefinition
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
            self.observer = center.addObserverForName(self.name, object: self.observable, queue: self.queue, usingBlock: self.handler.normalised as! NotificationObserverHandler)
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

public func ==(lhs: NotificationObserverHandlerDefinition, rhs: NotificationObserverHandlerDefinition) -> Bool {
    return true &&
        lhs.name == rhs.name &&
        lhs.observable === rhs.observable &&
        lhs.queue == rhs.queue &&
        NotificationObserver.compareBlocks(lhs.handler.original, rhs.handler.original)
}