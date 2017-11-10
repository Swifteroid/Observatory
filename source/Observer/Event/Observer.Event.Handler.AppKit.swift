import Foundation

extension EventObserver.Handler
{
    public struct AppKit
    {
        /// Global signature without event forwarding.
        public typealias GlobalSignature = (NSEvent) -> ()

        /// Local signature with event forwarding.
        public typealias LocalSignature = (NSEvent) -> NSEvent?

        open class Definition: ObserverHandlerDefinition
        {
            public typealias Handler = (global: GlobalSignature?, local: LocalSignature?)
            public typealias Monitor = (global: Any?, local: Any?)

            init(mask: NSEvent.EventTypeMask, handler: Handler) {
                self.mask = mask
                self.handler = handler
            }

            deinit {
                self.deactivate()
            }

            // MARK: -

            open let mask: NSEvent.EventTypeMask
            open let handler: Handler

            // MARK: -

            open private(set) var monitor: Monitor?

            // MARK: -

            open private(set) var active: Bool = false

            @discardableResult open func activate(_ newValue: Bool = true) -> Self {
                if newValue == self.active { return self }

                if newValue {
                    self.monitor = Monitor(
                        local: self.handler.local.map({ NSEvent.addLocalMonitorForEvents(matching: self.mask, handler: $0) as Any }),
                        global: self.handler.global.map({ NSEvent.addGlobalMonitorForEvents(matching: self.mask, handler: $0) as Any })
                    )
                } else if let monitor = self.monitor {
                    monitor.local.map({ NSEvent.removeMonitor($0) })
                    monitor.global.map({ NSEvent.removeMonitor($0) })
                    self.monitor = nil
                }

                self.active = newValue
                return self
            }

            @discardableResult open func deactivate() -> Self {
                return self.activate(false)
            }
        }
    }
}