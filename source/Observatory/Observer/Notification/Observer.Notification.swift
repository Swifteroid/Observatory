import Foundation

/// Notification observer provides an interface for registering and managing multiple notification handlers. When we register
/// notification handler observer creates handler definition – it manages that specific notification-handler association.
open class NotificationObserver: AbstractObserver {
    public init(active: Bool = false, center: NotificationCenter? = nil) {
        super.init()
        self.center = center
        self.activate(active)
    }

    open var center: NotificationCenter?

    open private(set) var definitions: [Handler.Definition] = []

    @discardableResult open func add(definition: Handler.Definition) -> Self {
        self.definitions.append(definition.activate(self.isActive))
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

    override open var isActive: Bool {
        get { super.isActive }
        set { self.activate(newValue) }
    }

    @discardableResult open func activate(_ newValue: Bool = true) -> Self {
        if newValue == self.isActive { return self }
        for definition in self.definitions { definition.activate(newValue, center: self.center) }
        super.isActive = newValue
        return self
    }

    @discardableResult open func deactivate() -> Self {
        self.activate(false)
    }

    // MARK: -

    @discardableResult open func add(name: Notification.Name, observee: AnyObject? = nil, queue: OperationQueue? = nil, handler: @escaping () -> Void) -> Self {
        self.add(definition: .init(name: name, observee: observee, queue: queue, handler: handler))
    }

    @discardableResult open func add(name: Notification.Name, observee: AnyObject? = nil, queue: OperationQueue? = nil, handler: @escaping (Notification) -> Void) -> Self {
        self.add(definition: .init(name: name, observee: observee, queue: queue, handler: handler))
    }

    @discardableResult open func add(names: [Notification.Name], observee: AnyObject? = nil, queue: OperationQueue? = nil, handler: @escaping () -> Void) -> Self {
        self.add(definitions: names.map({ .init(name: $0, observee: observee, queue: queue, handler: handler) }))
    }

    @discardableResult open func add(names: [Notification.Name], observee: AnyObject? = nil, queue: OperationQueue? = nil, handler: @escaping (Notification) -> Void) -> Self {
        self.add(definitions: names.map({ .init(name: $0, observee: observee, queue: queue, handler: handler) }))
    }

    @discardableResult open func remove(name: Notification.Name? = nil, observee: AnyObject? = nil, queue: OperationQueue? = nil) -> Self {
        self.remove(definitions: self.definitions.filter({
            (name != nil || observee != nil || queue != nil)
                && (name == nil || $0.name == name)
                && (observee == nil || $0.observee === observee)
                && (queue == nil || $0.queue == queue)
        }))
    }
}
