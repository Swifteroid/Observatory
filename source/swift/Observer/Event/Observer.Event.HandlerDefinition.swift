import Foundation

extension EventObserver
{
    public class HandlerDefinition: Equatable
    {
        public typealias SELF = HandlerDefinition
        public typealias Handler = (original: Any, global: Any?, local: Any?)
        public typealias Monitor = (global: AnyObject?, local: AnyObject?)

        public private(set) var mask: NSEventMask
        public private(set) var handler: Handler

        public private(set) var monitor: Monitor?

        // MARK: -

        init(mask: NSEventMask, handler: Handler) {
            self.mask = mask
            self.handler = handler
        }

        // MARK: -

        public func activate() -> SELF {
            if self.monitor == nil {
                var monitor: Monitor = Monitor(local: nil, global: nil)

                if let handler: GlobalEventHandler = self.handler.local as? GlobalEventHandler {
                    monitor.global = NSEvent.addGlobalMonitorForEventsMatchingMask(self.mask, handler: handler)
                }

                if let handler: LocalEventHandler = self.handler.local as? LocalEventHandler {
                    monitor.local = NSEvent.addLocalMonitorForEventsMatchingMask(self.mask, handler: handler)
                }

                self.monitor = monitor
            }
            return self
        }

        public func deactivate() -> SELF {
            if let monitor: Monitor = self.monitor {
                if let monitor: AnyObject = monitor.local {
                    NSEvent.removeMonitor(monitor)
                }

                if let monitor: AnyObject = monitor.global {
                    NSEvent.removeMonitor(monitor)
                }

                self.monitor = nil
            }
            return self
        }

        deinit {
            self.deactivate()
        }
    }
}

public func ==(left: EventObserver.HandlerDefinition, right: EventObserver.HandlerDefinition) -> Bool {
    return true &&
        left.mask == right.mask &&
        EventObserver.compareBlocks(left.handler.original, right.handler.original) &&
        (left.handler.global == nil && right.handler.global == nil || left.handler.global != nil && right.handler.global != nil) &&
        (left.handler.local == nil && right.handler.local == nil || left.handler.local != nil && right.handler.local != nil)
}