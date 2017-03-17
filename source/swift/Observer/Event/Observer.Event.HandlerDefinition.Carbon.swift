import Foundation

open class CarbonEventObserverHandlerDefinition: ObserverHandlerDefinitionProtocol
{
    public typealias Handler = (original: Any, normal: Any)

    open let mask: CGEventMask
    open let location: CGEventTapLocation
    open let placement: CGEventTapPlacement
    open let options: CGEventTapOptions
    open let handler: Handler

    private let loop: CFRunLoop
    private let source: CFRunLoopSource
    private let tap: CFMachPort

    // MARK: -

    open private(set) var active: Bool = false

    @discardableResult open func activate(_ newValue: Bool = true) -> Self {
        if newValue == self.active { return self }

        if newValue {
            CFRunLoopAddSource(self.loop, self.source, CFRunLoopMode.commonModes)
            CGEvent.tapEnable(tap: self.tap, enable: true)
        } else {
            CGEvent.tapEnable(tap: self.tap, enable: false)
            CFRunLoopRemoveSource(self.loop, self.source, CFRunLoopMode.commonModes)
        }

        self.active = newValue
        return self
    }

    @discardableResult open func deactivate() -> Self {
        return self.activate(false)
    }

    // MARK: -

    public init?(mask: CGEventMask, location: CGEventTapLocation, placement: CGEventTapPlacement, options: CGEventTapOptions, handler: Handler) {
        let handlerPointer: UnsafeMutablePointer<CarbonEventObserverHandler.Local> = UnsafeMutablePointer.allocate(capacity: 1)
        handlerPointer.initialize(to: handler.normal as! CarbonEventObserverHandler.Local)

        let callback: CGEventTapCallBack = { (proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, handler: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? in
            if let event: CGEvent = UnsafeMutablePointer<CarbonEventObserverHandler.Local>(OpaquePointer(handler!)).pointee(event) {
                return Unmanaged.passUnretained(event)
            } else {
                return nil
            }
        }

        guard let tap: CFMachPort = CGEvent.tapCreate(tap: location, place: placement, options: options, eventsOfInterest: mask, callback: callback, userInfo: handlerPointer) else {
            return nil
        }

        self.loop = CFRunLoopGetCurrent()
        self.source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        self.tap = tap

        self.mask = mask
        self.location = location
        self.placement = placement
        self.options = options
        self.handler = handler

    }

    deinit {
        self.deactivate()
    }
}

public func ==(lhs: CarbonEventObserverHandlerDefinition, rhs: CarbonEventObserverHandlerDefinition) -> Bool {
    return true &&
        lhs.mask == rhs.mask &&
        EventObserver.compareBlocks(lhs.handler.original, rhs.handler.original)
}