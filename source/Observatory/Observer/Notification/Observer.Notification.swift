import Foundation

/// Notification observer provides an interface for registering and managing multiple notification handlers. When we register
/// notification handler observer creates handler definition – it manages that specific notification-handler association.

open class NotificationObserver: AbstractObserver
{
    public init(active: Bool = false, center: NotificationCenter? = nil) {
        super.init()
        self.center = center
        self.activate(active)
    }

    // MARK: -

    open var center: NotificationCenter?

    open private(set) var definitions: [Handler.Definition] = []

    @discardableResult open func add(definition: Handler.Definition) -> Self {
        self.definitions.append(definition.activate(self.active))
        return self
    }

    @discardableResult open func add(definitions: [Handler.Definition]) -> Self {
        for definition in definitions { self.add(definition: definition) }
        return self
    }

    @discardableResult open func remove(definition: Handler.Definition) -> Self {
        self.definitions.enumerated().first(where: { $0.1 === definition }).map({ self.definitions.remove(at: $0.0) })?.deactivate()
        return self
    }

    @discardableResult open func remove(definitions: [Handler.Definition]) -> Self {
        for definition in definitions { self.remove(definition: definition) }
        return self
    }

    // MARK: -

    override open var active: Bool {
        get { return super.active }
        set { self.activate(newValue) }
    }

    @discardableResult open func activate(_ newValue: Bool = true) -> Self {
        if newValue == self.active { return self }
        for definition in self.definitions { definition.activate(newValue, center: self.center) }
        super.active = newValue
        return self
    }

    @discardableResult open func deactivate() -> Self {
        return self.activate(false)
    }
}

extension NotificationObserver
{
    @discardableResult open func add(name: Notification.Name, observee: AnyObject? = nil, queue: OperationQueue? = nil, handler: @escaping () -> ()) -> Self {
        return self.add(definition: Handler.Definition(name: name, observee: observee, queue: queue, handler: { _ in handler() }))
    }

    @discardableResult open func add(name: Notification.Name, observee: AnyObject? = nil, queue: OperationQueue? = nil, handler: @escaping (Notification) -> ()) -> Self {
        return self.add(definition: Handler.Definition(name: name, observee: observee, queue: queue, handler: handler))
    }

    @discardableResult open func add(names: [Notification.Name], observee: AnyObject? = nil, queue: OperationQueue? = nil, handler: @escaping () -> ()) -> Self {
        return self.add(names: names, observee: observee, queue: queue, handler: { _ in handler() })
    }

    @discardableResult open func add(names: [Notification.Name], observee: AnyObject? = nil, queue: OperationQueue? = nil, handler: @escaping (Notification) -> ()) -> Self {
        names.forEach({ _ = self.add(name: $0, observee: observee, queue: queue, handler: handler) })
        return self
    }

    @discardableResult open func remove(name: Notification.Name? = nil, observee: AnyObject? = nil, queue: OperationQueue? = nil) -> Self {
        self.definitions.filter({ (name != nil || observee != nil || queue != nil) && (name == nil || $0.name == name) && (observee == nil || $0.observee === observee) && (queue == nil || $0.queue == queue) }).forEach({ _ = self.remove(definition: $0) })
        return self
    }
}