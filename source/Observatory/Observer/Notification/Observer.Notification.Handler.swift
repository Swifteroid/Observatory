import Foundation

extension NotificationObserver {
    public struct Handler {
        public typealias Signature = (Notification) -> Void

        open class Definition: ObserverHandlerDefinition {
            deinit {
                self.deactivate()
            }

            init(name: Notification.Name, observee: AnyObject?, queue: OperationQueue?, handler: @escaping Signature) {
                self.name = name
                self.observee = observee
                self.queue = queue
                self.handler = handler
            }

            public let name: Notification.Name
            open private(set) weak var observee: AnyObject?
            public let queue: OperationQueue?
            public let handler: Signature

            open private(set) var monitor: AnyObject?
            open private(set) var center: NotificationCenter?

            open private(set) var isActive: Bool = false

            @discardableResult open func activate(_ newValue: Bool = true, center: NotificationCenter? = nil) -> Self {
                if newValue == self.isActive { return self }

                if newValue {
                    let center = center ?? self.center ?? NotificationCenter.default
                    self.monitor = center.addObserver(forName: self.name, object: self.observee, queue: self.queue, using: self.handler)
                    self.center = center
                } else if let center = self.center, let monitor = self.monitor {
                    center.removeObserver(monitor)
                    self.monitor = nil
                    self.center = nil
                }

                self.isActive = newValue
                return self
            }

            @discardableResult open func deactivate() -> Self {
                self.activate(false)
            }
        }
    }
}

/// Convenience initializers.
extension NotificationObserver.Handler.Definition {
    public convenience init(name: Notification.Name, observee: AnyObject? = nil, queue: OperationQueue? = nil, handler: @escaping () -> Void) {
        self.init(name: name, observee: observee, queue: queue, handler: { _ in handler() })
    }
}
