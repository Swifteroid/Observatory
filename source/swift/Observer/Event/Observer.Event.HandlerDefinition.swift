import Foundation

public class EventObserverHandlerDefinition: ObserverHandlerDefinition, Equatable
{
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

    public func activate() -> Self {
        if self.monitor == nil {
            var monitor: Monitor = Monitor(local: nil, global: nil)

            if let handler: EventObserverHandler.Global = self.handler.local as? EventObserverHandler.Global {
                monitor.global = NSEvent.addGlobalMonitorForEventsMatchingMask(self.mask, handler: handler)
            }

            if let handler: EventObserverHandler.Local = self.handler.local as? EventObserverHandler.Local {
                monitor.local = NSEvent.addLocalMonitorForEventsMatchingMask(self.mask, handler: handler)
            }

            self.monitor = monitor
        }

        return self
    }

    public func deactivate() -> Self {
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

public func ==(lhs: EventObserverHandlerDefinition, rhs: EventObserverHandlerDefinition) -> Bool {
    return true &&
        lhs.mask == rhs.mask &&
        EventObserver.compareBlocks(lhs.handler.original, rhs.handler.original) &&
        (lhs.handler.global == nil && rhs.handler.global == nil || lhs.handler.global != nil && rhs.handler.global != nil) &&
        (lhs.handler.local == nil && rhs.handler.local == nil || lhs.handler.local != nil && rhs.handler.local != nil)
}