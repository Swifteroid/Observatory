import Foundation

open class NotificationObserverHandlerDefinition: ObserverHandlerDefinitionProtocol
{
    public typealias Handler = (original: Any, normalised: Any)

    open let name: Notification.Name
    open let observable: AnyObject?
    open let queue: OperationQueue?
    open let handler: Handler

    // MARK: -

    open private(set) var observer: AnyObject?
    open private(set) var center: NotificationCenter?

    // MARK: -

    open private(set) var active: Bool = false

    @discardableResult open func activate(_ newValue: Bool = true, center: NotificationCenter? = nil) -> Self {
        if newValue == self.active { return self }

        let center: NotificationCenter = center ?? self.center ?? NotificationCenter.default

        if newValue {
            let observer: AnyObject = center.addObserver(forName: self.name, object: self.observable, queue: self.queue, using: self.handler.normalised as! NotificationObserverHandler)
            self.observer = observer
            self.center = center
        } else {
            self.center!.removeObserver(self.observer!)
            self.observer = nil
            self.center = nil
        }

        self.active = newValue
        return self
    }

    @discardableResult open func deactivate() -> Self {
        return self.activate(false)
    }

    // MARK: -

    init(name: Notification.Name, observable: AnyObject?, queue: OperationQueue?, handler: Handler) {
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