import Foundation

extension NotificationObserver
{
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
    return true &&
        left.name == right.name &&
        left.observable === right.observable &&
        left.queue == right.queue &&
        NotificationObserver.compareBlocks(left.handler.original, right.handler.original)
}