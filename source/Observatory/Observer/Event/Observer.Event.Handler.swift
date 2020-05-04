import Foundation

extension EventObserver {
    public struct Handler {
    }
}

extension EventObserver.Handler {
    public struct AppKit {
        /// Global signature without event forwarding.
        public typealias GlobalSignature = (NSEvent) -> Void

        /// Local signature with event forwarding.
        public typealias LocalSignature = (NSEvent) -> NSEvent?

        open class Definition: ObserverHandlerDefinition {
            public typealias Handler = (global: GlobalSignature?, local: LocalSignature?)
            public typealias Monitor = (global: Any?, local: Any?)

            init(mask: NSEvent.EventTypeMask, handler: Handler) {
                self.mask = mask
                self.handler = handler
            }

            deinit {
                self.deactivate()
            }

            public let mask: NSEvent.EventTypeMask
            public let handler: Handler

            open private(set) var monitor: Monitor?

            open private(set) var isActive: Bool = false

            @discardableResult open func activate(_ newValue: Bool = true) -> Self {
                if newValue == self.isActive { return self }

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
extension EventObserver.Handler.AppKit.Definition {

    /// Initialize with local + global handler.
    public convenience init(mask: NSEvent.EventTypeMask, local: ((NSEvent) -> NSEvent?)?, global: ((NSEvent) -> Void)?) {
        self.init(mask: mask, handler: (global: global, local: local))
    }

    /// Initialize with local + global handler with manual local event forwarding.
    public convenience init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent) -> NSEvent?) {
        self.init(mask: mask, local: handler, global: { _ = handler($0) })
    }

    /// Initialize with local + global handler with custom local event forwarding.
    /// - parameter forward: Specifies whether to forward the event or not, default is `true`.
    public convenience init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent) -> Void, forward: Bool = true) {
        /*@formatter:off*/ self.init(mask: mask, local: { handler($0); return forward ? $0 : nil }, global: handler) /*@formatter:on*/
    }

    /// Initialize with local + global handler with custom local event forwarding.
    /// - parameter forward: Specifies whether to forward the event or not, default is `true`.
    public convenience init(mask: NSEvent.EventTypeMask, handler: @escaping () -> Void, forward: Bool = true) {
        /*@formatter:off*/ self.init(mask: mask, local: { handler(); return forward ? $0 : nil }, global: { _ in handler() }) /*@formatter:on*/
    }

    /// Initialize with local handler with manual event forwarding.
    public convenience init(mask: NSEvent.EventTypeMask, local: @escaping (NSEvent) -> NSEvent?) {
        self.init(mask: mask, local: local, global: nil)
    }

    /// Initialize with local handler with custom local event forwarding.
    /// - parameter forward: Specifies whether to forward the event or not, default is `true`.
    public convenience init(mask: NSEvent.EventTypeMask, local: @escaping (NSEvent) -> Void, forward: Bool = true) {
        /*@formatter:off*/ self.init(mask: mask, local: { local($0); return forward ? $0 : nil }, global: nil) /*@formatter:on*/
    }

    /// Initialize with local handler with custom local event forwarding.
    /// - parameter forward: Specifies whether to forward the event or not, default is `true`.
    public convenience init(mask: NSEvent.EventTypeMask, local: @escaping () -> Void, forward: Bool = true) {
        /*@formatter:off*/ self.init(mask: mask, local: { local(); return forward ? $0 : nil }, global: nil) /*@formatter:on*/
    }

    /// Initialize with global handler.
    public convenience init(mask: NSEvent.EventTypeMask, global: @escaping (NSEvent) -> Void) {
        self.init(mask: mask, local: nil, global: global)
    }

    /// Initialize with global handler.
    public convenience init(mask: NSEvent.EventTypeMask, global: @escaping () -> Void) {
        self.init(mask: mask, local: nil, global: { _ in global() })
    }
}

extension EventObserver.Handler {
    public struct Carbon {
        public typealias Signature = (CGEvent) -> CGEvent?

        open class Definition: ObserverHandlerDefinition {
            public init?(mask: CGEventMask, location: CGEventTapLocation, placement: CGEventTapPlacement, options: CGEventTapOptions, handler: @escaping Signature) {

                // We may receive events that we didn't ask for, like null, tapDisabledByTimeout or tapDisabledByUserInput. To avoid it we must check
                // that event mask matches the specified, kudos to https://bugs.swift.org/browse/SR-4073.

                let userInfo: UnsafeMutablePointer<Signature> = UnsafeMutablePointer.allocate(capacity: 1)
                userInfo.initialize(to: { mask & CGEventMask(1 << $0.type.rawValue) > 0 ? handler($0) : $0 })

                let callback: CGEventTapCallBack = { (proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, handler: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? in
                    UnsafeMutablePointer<Signature>(OpaquePointer(handler!)).pointee(event).map({ Unmanaged.passUnretained($0) })
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

            public let mask: CGEventMask
            public let location: CGEventTapLocation
            public let placement: CGEventTapPlacement
            public let options: CGEventTapOptions
            public let handler: Signature

            private let loop: CFRunLoop
            private let source: CFRunLoopSource
            private let tap: CFMachPort
            private let userInfo: UnsafeMutablePointer<Signature>

            open var isActive: Bool {
                CGEvent.tapIsEnabled(tap: self.tap) && CFRunLoopContainsSource(self.loop, self.source, .commonModes)
            }

            @discardableResult open func activate(_ newValue: Bool = true) -> Self {
                if newValue == self.isActive { return self }

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
                self.activate(false)
            }
        }
    }
}

/// Convenience initializers.
extension EventObserver.Handler.Carbon.Definition {

    /// Initialize with manual event forwarding.
    public convenience init?(mask: CGEventMask, location: CGEventTapLocation? = nil, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping (CGEvent) -> CGEvent?) {
        self.init(mask: mask, location: location ?? .cgSessionEventTap, placement: placement ?? .headInsertEventTap, options: options ?? .defaultTap, handler: handler)
    }

    /// Initialize with automatic event forwarding.
    public convenience init?(mask: CGEventMask, location: CGEventTapLocation? = nil, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping (CGEvent) -> Void) {
        /*@formatter:off*/ self.init(mask: mask, location: location, placement: placement, options: options, handler: { handler($0); return $0 } as EventObserver.Handler.Carbon.Signature) /*@formatter:on*/
    }

    /// Initialize with automatic event forwarding.
    public convenience init?(mask: CGEventMask, location: CGEventTapLocation? = nil, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping () -> Void) {
        /*@formatter:off*/ self.init(mask: mask, location: location, placement: placement, options: options, handler: { handler(); return $0 } as EventObserver.Handler.Carbon.Signature) /*@formatter:on*/
    }

    /// Initialize with manual event forwarding.
    public convenience init?(mask: NSEvent.EventTypeMask, location: CGEventTapLocation?, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping (CGEvent) -> CGEvent?) {
        self.init(mask: mask.rawValue, location: location, placement: placement, options: options, handler: handler)
    }

    /// Initialize with automatic event forwarding.
    public convenience init?(mask: NSEvent.EventTypeMask, location: CGEventTapLocation?, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping (CGEvent) -> Void) {
        self.init(mask: mask.rawValue, location: location, placement: placement, options: options, handler: handler)
    }

    /// Initialize with automatic event forwarding.
    public convenience init?(mask: NSEvent.EventTypeMask, location: CGEventTapLocation?, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping () -> Void) {
        self.init(mask: mask.rawValue, location: location, placement: placement, options: options, handler: handler)
    }
}
