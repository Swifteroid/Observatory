import Foundation
import CoreGraphics

/// Event observer provides a flexible interface for registering and managing multiple event handlers in, both, global
/// and local contexts.
open class EventObserver: AbstractObserver {
    deinit {
        self.deactivate()
    }

    public convenience init(active: Bool) {
        self.init()
        self.activate(active)
    }

    open internal(set) var appKitDefinitions: [Handler.AppKit.Definition] = []
    open internal(set) var carbonDefinitions: [Handler.Carbon.Definition] = []

    @discardableResult open func add(definition: Handler.AppKit.Definition) -> Self {
        self.appKitDefinitions.append(definition.activate(self.isActive))
        return self
    }

    @discardableResult open func add(definitions: [Handler.AppKit.Definition]) -> Self {
        for definition in definitions { self.add(definition: definition) }
        return self
    }

    @discardableResult open func add(definition: Handler.Carbon.Definition) -> Self {
        self.carbonDefinitions.append(definition.activate(self.isActive))
        return self
    }

    @discardableResult open func add(definitions: [Handler.Carbon.Definition]) -> Self {
        for definition in definitions { self.add(definition: definition) }
        return self
    }

    @discardableResult open func remove(definition: Handler.AppKit.Definition) -> Self {
        self.appKitDefinitions.enumerated().first(where: { $0.1 === definition }).map({ self.appKitDefinitions.remove(at: $0.0) })?.deactivate()
        return self
    }

    @discardableResult open func remove(definitions: [Handler.AppKit.Definition]) -> Self {
        for definition in definitions { self.remove(definition: definition) }
        return self
    }

    @discardableResult open func remove(definition: Handler.Carbon.Definition) -> Self {
        self.carbonDefinitions.enumerated().first(where: { $0.1 === definition }).map({ self.appKitDefinitions.remove(at: $0.0) })?.deactivate()
        return self
    }

    @discardableResult open func remove(definitions: [Handler.Carbon.Definition]) -> Self {
        for definition in definitions { self.remove(definition: definition) }
        return self
    }

    override open var isActive: Bool {
        get { super.isActive }
        set { self.activate(newValue) }
    }

    @discardableResult open func activate(_ newValue: Bool = true) -> Self {

        // Todo: we should use common store for all definitions where they would be kept in the order
        // todo: of adding, so we can maintain that order during activation / deactivation.

        if newValue == self.isActive { return self }
        for definition in self.carbonDefinitions { definition.activate(newValue) }
        for definition in self.appKitDefinitions { definition.activate(newValue) }
        super.isActive = newValue
        return self
    }

    @discardableResult open func deactivate() -> Self {
        self.activate(false)
    }
}

// NSEvent with local + global handler.
extension EventObserver {

    /// Register AppKit local + global handler.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, local: ((NSEvent) -> NSEvent?)?, global: ((NSEvent) -> Void)?) -> Self {
        self.add(definition: .init(mask: mask, local: local, global: global))
    }

    /// Register AppKit local + global handler with manual local event forwarding.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent) -> NSEvent?) -> Self {
        self.add(definition: .init(mask: mask, handler: handler))
    }

    /// Register AppKit local + global handler with custom local event forwarding.
    /// - parameter forward: Specifies whether to forward the event or not, default is `true`.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent) -> Void, forward: Bool = true) -> Self {
        self.add(definition: .init(mask: mask, handler: handler, forward: forward))
    }

    /// Register AppKit local + global handler with custom local event forwarding.
    /// - parameter forward: Specifies whether to forward the event or not, default is `true`.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, handler: @escaping () -> Void, forward: Bool = true) -> Self {
        self.add(definition: .init(mask: mask, handler: handler, forward: forward))
    }

    /// Remove all handlers with specified mask.
    @discardableResult open func remove(mask: NSEvent.EventTypeMask) -> Self {
        self.remove(definitions: self.appKitDefinitions.filter({ $0.mask == mask }))
    }
}

/// NSEvent with local handler.
extension EventObserver {

    /// Register AppKit local handler with manual event forwarding.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, local: @escaping (NSEvent) -> NSEvent?) -> Self {
        self.add(definition: .init(mask: mask, local: local))
    }

    /// Register AppKit local handler with custom local event forwarding.
    /// - parameter forward: Specifies whether to forward the event or not, default is `true`.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, local: @escaping (NSEvent) -> Void, forward: Bool = true) -> Self {
        self.add(definition: .init(mask: mask, local: local, forward: forward))
    }

    /// Register AppKit local handler with custom local event forwarding.
    /// - parameter forward: Specifies whether to forward the event or not, default is `true`.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, local: @escaping () -> Void, forward: Bool = true) -> Self {
        self.add(definition: .init(mask: mask, local: local, forward: forward))
    }
}

/// NSEvent with global handler.
extension EventObserver {

    /// Register AppKit global handler.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, global: @escaping (NSEvent) -> Void) -> Self {
        self.add(definition: .init(mask: mask, global: global))
    }

    /// Register AppKit global handler.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, global: @escaping () -> Void) -> Self {
        self.add(definition: .init(mask: mask, global: global))
    }
}

/// Needed for below.
extension EventObserver {
    fileprivate func add(definition: Handler.Carbon.Definition?) -> Self {
        if let definition: Handler.Carbon.Definition = definition { return self.add(definition: definition) } else { return self }
    }
}

/// CGEvent with CGEventMask.
extension EventObserver {

    /// Register CoreGraphics handler with manual event forwarding.
    @discardableResult open func add(mask: CGEventMask, location: CGEventTapLocation? = nil, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping (CGEvent) -> CGEvent?) -> Self {
        self.add(definition: Handler.Carbon.Definition(mask: mask, location: location, placement: placement, options: options, handler: handler))
    }

    /// Register CoreGraphics handler with automatic event forwarding.
    @discardableResult open func add(mask: CGEventMask, location: CGEventTapLocation? = nil, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping (CGEvent) -> Void) -> Self {
        self.add(definition: Handler.Carbon.Definition(mask: mask, location: location, placement: placement, options: options, handler: handler))
    }

    /// Register CoreGraphics handler with automatic event forwarding.
    @discardableResult open func add(mask: CGEventMask, location: CGEventTapLocation? = nil, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping () -> Void) -> Self {
        self.add(definition: Handler.Carbon.Definition(mask: mask, location: location, placement: placement, options: options, handler: handler))
    }

    @discardableResult open func remove(mask: CGEventMask) -> Self {
        self.remove(definitions: self.carbonDefinitions.filter({ $0.mask == mask }))
    }
}

/// CGEvent with NSEvent.EventTypeMask.
extension EventObserver {

    /// Register CoreGraphics handler with manual event forwarding.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, location: CGEventTapLocation?, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping (CGEvent) -> CGEvent?) -> Self {
        self.add(definition: Handler.Carbon.Definition(mask: mask.rawValue, location: location, placement: placement, options: options, handler: handler))
    }

    /// Register CoreGraphics handler with automatic event forwarding.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, location: CGEventTapLocation?, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping (CGEvent) -> Void) -> Self {
        self.add(definition: Handler.Carbon.Definition(mask: mask.rawValue, location: location, placement: placement, options: options, handler: handler))
    }

    /// Register CoreGraphics handler with automatic event forwarding.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, location: CGEventTapLocation?, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping () -> Void) -> Self {
        self.add(definition: Handler.Carbon.Definition(mask: mask.rawValue, location: location, placement: placement, options: options, handler: handler))
    }
}
