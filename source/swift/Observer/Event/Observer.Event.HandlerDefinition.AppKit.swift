import Foundation

open class AppKitEventObserverHandlerDefinition: ObserverHandlerDefinitionProtocol
{
    public typealias Handler = (original: Any, global: Any?, local: Any?)
    public typealias Monitor = (global: Any?, local: Any?)

    open let mask: NSEventMask
    open let handler: Handler

    // MARK: -

    open private(set) var monitor: Monitor?

    // MARK: -

    open private(set) var active: Bool = false

    @discardableResult open func activate(_ newValue: Bool = true) -> Self {
        if newValue == self.active { return self }

        if newValue {
            var monitor: Monitor = Monitor(local: nil, global: nil)
            if let handler: AppKitEventObserverHandler.Local = self.handler.local as? AppKitEventObserverHandler.Local { monitor.local = NSEvent.addLocalMonitorForEvents(matching: self.mask, handler: handler) }
            if let handler: AppKitEventObserverHandler.Global = self.handler.local as? AppKitEventObserverHandler.Global { monitor.global = NSEvent.addGlobalMonitorForEvents(matching: self.mask, handler: handler) }
            self.monitor = monitor
        } else {
            let monitor: Monitor = self.monitor!
            if let monitor: Any = monitor.local { NSEvent.removeMonitor(monitor) }
            if let monitor: Any = monitor.global { NSEvent.removeMonitor(monitor) }
            self.monitor = nil

        }

        self.active = newValue
        return self
    }

    @discardableResult open func deactivate() -> Self {
        return self.activate(false)
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

public func ==(lhs: AppKitEventObserverHandlerDefinition, rhs: AppKitEventObserverHandlerDefinition) -> Bool {
    return true &&
        lhs.mask == rhs.mask &&
        EventObserver.compareBlocks(lhs.handler.original, rhs.handler.original) &&
        (lhs.handler.global == nil && rhs.handler.global == nil || lhs.handler.global != nil && rhs.handler.global != nil) &&
        (lhs.handler.local == nil && rhs.handler.local == nil || lhs.handler.local != nil && rhs.handler.local != nil)
}