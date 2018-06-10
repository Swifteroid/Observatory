import Foundation

extension EventObserver
{
    public struct Handler
    {
    }
}

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

            open let mask: NSEvent.EventTypeMask
            open let handler: Handler

            open private(set) var monitor: Monitor?

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

extension EventObserver.Handler
{
    public struct Carbon
    {
        public typealias Signature = (CGEvent) -> CGEvent?

        open class Definition: ObserverHandlerDefinition
        {
            public init?(mask: CGEventMask, location: CGEventTapLocation, placement: CGEventTapPlacement, options: CGEventTapOptions, handler: @escaping Signature) {

                // We may receive events that we didn't ask for, like null, tapDisabledByTimeout or tapDisabledByUserInput. To avoid it we must check
                // that event mask matches the specified, kudos to https://bugs.swift.org/browse/SR-4073.

                let userInfo: UnsafeMutablePointer<Signature> = UnsafeMutablePointer.allocate(capacity: 1)
                userInfo.initialize(to: { mask & CGEventMask(1 << $0.type.rawValue) > 0 ? handler($0) : $0 })

                let callback: CGEventTapCallBack = { (proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, handler: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? in
                    return UnsafeMutablePointer<Signature>(OpaquePointer(handler!)).pointee(event).map({ Unmanaged.passUnretained($0) })
                }

                // Tap should be initially disabled – it shouldn't play any role unless it's added to a loop, frankly it never did until recent,
                // but it messes up event flow and sometimes events get blocked, for example, when adding inactive mouse down observer.

                guard let tap: CFMachPort = CGEvent.tapCreate(tap: location, place: placement, options: options, eventsOfInterest: mask, callback: callback, userInfo: userInfo) else { return nil }
                CGEvent.tapEnable(tap: tap, enable: false)

                self.loop = CFRunLoopGetCurrent()
                self.source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
                self.tap = tap
                self.userInfo = userInfo

                self.mask = mask
                self.location = location
                self.placement = placement
                self.options = options
                self.handler = handler
            }

            deinit {
                self.deactivate()
                self.userInfo.deinitialize(count: 1)
                self.userInfo.deallocate()
            }

            open let mask: CGEventMask
            open let location: CGEventTapLocation
            open let placement: CGEventTapPlacement
            open let options: CGEventTapOptions
            open let handler: Signature

            private let loop: CFRunLoop
            private let source: CFRunLoopSource
            private let tap: CFMachPort
            private let userInfo: UnsafeMutablePointer<Signature>

            open var active: Bool {
                return CGEvent.tapIsEnabled(tap: self.tap) && CFRunLoopContainsSource(self.loop, self.source, .commonModes)
            }

            @discardableResult open func activate(_ newValue: Bool = true) -> Self {
                if newValue == self.active { return self }

                if newValue {
                    CFRunLoopAddSource(self.loop, self.source, .commonModes)
                    CGEvent.tapEnable(tap: self.tap, enable: true)
                } else {
                    CGEvent.tapEnable(tap: self.tap, enable: false)
                    CFRunLoopRemoveSource(self.loop, self.source, .commonModes)
                }

                return self
            }

            @discardableResult open func deactivate() -> Self {
                return self.activate(false)
            }
        }
    }
}