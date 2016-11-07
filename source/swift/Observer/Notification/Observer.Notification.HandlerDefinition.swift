import Foundation

public class NotificationObserverHandlerDefinition: ObserverHandlerDefinitionProtocol
{
    public typealias SELF = NotificationObserverHandlerDefinition
    public typealias Handler = (original: Any, normalised: Any)

    public let name: String
    public let observable: AnyObject?
    public let queue: NSOperationQueue?
    public let handler: Handler

    // MARK: -

    public private(set) var observer: AnyObject!
    public private(set) var center: NSNotificationCenter!

    // MARK: -

    public private(set) var active: Bool = false

    public func activate(center: NSNotificationCenter) -> NotificationObserverHandlerDefinition {
        guard self.inactive else {
            return self
        }

        let observer: AnyObject = center.addObserverForName(self.name, object: self.observable, queue: self.queue, usingBlock: self.handler.normalised as! NotificationObserverHandler)

        self.observer = observer
        self.center = center
        self.active = true

        return self
    }

    public func deactivate() -> Self {
        guard self.active else {
            return self
        }

        self.center.removeObserver(self.observer)

        self.observer = nil
        self.center = nil
        self.active = false

        return self
    }

    // MARK: -

    init(name: String, observable: AnyObject?, queue: NSOperationQueue?, handler: Handler) {
        self.name = name
        self.observable = observable
        self.queue = queue
        self.handler = handler
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