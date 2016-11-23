import Foundation

open class EventObserverHandlerDefinition: ObserverHandlerDefinitionProtocol
{
    public typealias Handler = (original: Any, global: Any?, local: Any?)
    public typealias Monitor = (global: AnyObject?, local: AnyObject?)

    open let mask: NSEventMask
    open let handler: Handler

    // MARK: -

    open private(set) var monitor: Monitor!

    // MARK: -

    open private(set) var active: Bool = false

    @discardableResult open func activate() -> EventObserverHandlerDefinition {
        guard self.inactive else {
            return self
        }

        var monitor: Monitor = Monitor(local: nil, global: nil)

        if let handler: EventObserverHandler.Global = self.handler.local as? EventObserverHandler.Global {
            monitor.global = NSEvent.addGlobalMonitorForEvents(matching: self.mask, handler: handler) as AnyObject?
        }

        if let handler: EventObserverHandler.Local = self.handler.local as? EventObserverHandler.Local {
            monitor.local = NSEvent.addLocalMonitorForEvents(matching: self.mask, handler: handler) as AnyObject?
        }

        self.monitor = monitor
        self.active = true

        return self
    }

    @discardableResult open func deactivate() -> Self {
        guard self.active else {
            return self
        }

        let monitor: Monitor = self.monitor

        if let monitor: AnyObject = monitor.local {
            NSEvent.removeMonitor(monitor)
        }

        if let monitor: AnyObject = monitor.global {
            NSEvent.removeMonitor(monitor)
        }

        self.monitor = nil
        self.active = false

        return self
    }

    // MARK: -

    init(mask: NSEventMask, handler: Handler) {
        self.mask = mask
        self.handler = handler
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