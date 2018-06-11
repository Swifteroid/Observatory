import Foundation

extension NotificationObserver
{
    public struct Handler
    {
        public typealias Signature = (Notification) -> ()

        open class Definition: ObserverHandlerDefinition
        {
            init(name: Notification.Name, observee: AnyObject?, queue: OperationQueue?, handler: @escaping Signature) {
                self.name = name
                self.observee = observee
                self.queue = queue
                self.handler = handler
            }

            deinit {
                self.deactivate()
            }

            open let name: Notification.Name
            open private(set) weak var observee: AnyObject?
            open let queue: OperationQueue?
            open let handler: Signature

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
                return self.activate(false)
            }
        }
    }
}