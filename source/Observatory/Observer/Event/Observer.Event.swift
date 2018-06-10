import Foundation
import CoreGraphics

/// Event observer provides a flexible interface for registering and managing multiple event handlers in, both, global
/// and local contexts.
open class EventObserver: AbstractObserver
{
    public convenience init(active: Bool) {
        self.init()
        self.activate(active)
    }

    open internal(set) var appKitDefinitions: [Handler.AppKit.Definition] = []
    open internal(set) var carbonDefinitions: [Handler.Carbon.Definition] = []

    @discardableResult open func add(definition: Handler.AppKit.Definition) -> Self {
        self.appKitDefinitions.append(definition.activate(self.active))
        return self
    }

    @discardableResult open func add(definitions: [Handler.AppKit.Definition]) -> Self {
        for definition in definitions { self.add(definition: definition) }
        return self
    }

    @discardableResult open func add(definition: Handler.Carbon.Definition) -> Self {
        self.carbonDefinitions.append(definition.activate(self.active))
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

    override open var active: Bool {
        get { return super.active }
        set { self.activate(newValue) }
    }

    @discardableResult open func activate(_ newValue: Bool = true) -> Self {

        // Todo: we should use common store for all definitions where they would be kept in the order 
        // todo: of adding, so we can maintain that order during activation / deactivation.

        if newValue == self.active { return self }
        for definition in self.carbonDefinitions { definition.activate(newValue) }
        for definition in self.appKitDefinitions { definition.activate(newValue) }
        super.active = newValue
        return self
    }

    @discardableResult open func deactivate() -> Self {
        return self.activate(false)
    }
}

// NSEvent
extension EventObserver
{
    @discardableResult open func add(mask: NSEvent.EventTypeMask, local: ((NSEvent) -> NSEvent?)?, global: ((NSEvent) -> ())?) -> Self {
        return self.add(definition: Handler.AppKit.Definition(
            mask: mask,
            handler: (global: global, local: local)))
    }

    /// Register AppKit local + global handler with manual local event forwarding.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent) -> NSEvent?) -> Self {
        return self.add(mask: mask, local: handler, global: { _ = handler($0) })
    }

    /// Register AppKit local + global handler with custom local event forwarding.
    /// - parameter forward: Specifies whether to forward the event or not, default is `true`.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent) -> (), forward: Bool = true) -> Self {
        /*@formatter:off*/ return self.add(mask: mask, local: { handler($0); return forward ? $0 : nil }, global: handler) /*@formatter:on*/
    }

    /// Register AppKit local + global handler with custom local event forwarding.
    /// - parameter forward: Specifies whether to forward the event or not, default is `true`.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, handler: @escaping () -> (), forward: Bool = true) -> Self {
        /*@formatter:off*/ return self.add(mask: mask, local: { handler(); return forward ? $0 : nil }, global: { _ in handler() }) /*@formatter:on*/
    }

    /// Remove all handlers with specified mask.
    @discardableResult open func remove(mask: NSEvent.EventTypeMask) -> Self {
        self.appKitDefinitions.filter({ $0.mask == mask }).forEach({ _ = self.remove(definition: $0) })
        return self
    }
}

extension EventObserver
{

    /// Register AppKit local handler with manual event forwarding.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, local: @escaping (NSEvent) -> NSEvent?) -> Self {
        return self.add(mask: mask, local: local, global: nil)
    }

    /// Register AppKit local handler with custom local event forwarding.
    /// - parameter forward: Specifies whether to forward the event or not, default is `true`.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, local: @escaping (NSEvent) -> (), forward: Bool = true) -> Self {
        /*@formatter:off*/ return self.add(mask: mask, local: { local($0); return forward ? $0 : nil }, global: nil) /*@formatter:on*/
    }

    /// Register AppKit local handler with custom local event forwarding.
    /// - parameter forward: Specifies whether to forward the event or not, default is `true`.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, local: @escaping () -> (), forward: Bool = true) -> Self {
        /*@formatter:off*/ return self.add(mask: mask, local: { local(); return forward ? $0 : nil }, global: nil) /*@formatter:on*/
    }
}

extension EventObserver
{

    /// Register AppKit global handler.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, global: @escaping (NSEvent) -> ()) -> Self {
        return self.add(mask: mask, local: nil, global: global)
    }

    /// Register AppKit global handler.
    @discardableResult open func add(mask: NSEvent.EventTypeMask, global: @escaping () -> ()) -> Self {
        return self.add(mask: mask, local: nil, global: { _ in global() })
    }
}

/// CGEvent
extension EventObserver
{

    /// Register CoreGraphics handler with manual event forwarding.
    @discardableResult open func add(mask: CGEventMask, location: CGEventTapLocation? = nil, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping (CGEvent) -> CGEvent?) -> Self {
        return Handler.Carbon.Definition(
            mask: mask,
            location: location ?? .cgSessionEventTap,
            placement: placement ?? .headInsertEventTap,
            options: options ?? .defaultTap,
            handler: handler).map({ self.add(definition: $0) }) ?? self
    }

    /// Register CoreGraphics handler with automatic event forwarding.
    @discardableResult open func add(mask: CGEventMask, location: CGEventTapLocation? = nil, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping (CGEvent) -> ()) -> Self {
        /*@formatter:off*/ return self.add(mask: mask, location: location, placement: placement, options: options, handler: { handler($0); return $0 } as Handler.Carbon.Signature) /*@formatter:on*/
    }

    /// Register CoreGraphics handler with automatic event forwarding.
    @discardableResult open func add(mask: CGEventMask, location: CGEventTapLocation? = nil, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping () -> ()) -> Self {
        /*@formatter:off*/ return self.add(mask: mask, location: location, placement: placement, options: options, handler: { handler(); return $0 } as Handler.Carbon.Signature) /*@formatter:on*/
    }

    @discardableResult open func remove(mask: CGEventMask) -> Self {
        self.carbonDefinitions.filter({ $0.mask == mask }).forEach({ _ = self.remove(definition: $0) })
        return self
    }
}

/// CGEvent with NSEvent.EventTypeMask
extension EventObserver
{
    @discardableResult open func add(mask: NSEvent.EventTypeMask, location: CGEventTapLocation?, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping (CGEvent) -> CGEvent?) -> Self {
        return self.add(mask: mask.rawValue, location: location, placement: placement, options: options, handler: handler)
    }

    @discardableResult open func add(mask: NSEvent.EventTypeMask, location: CGEventTapLocation?, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping (CGEvent) -> ()) -> Self {
        return self.add(mask: mask.rawValue, location: location, placement: placement, options: options, handler: handler)
    }

    @discardableResult open func add(mask: NSEvent.EventTypeMask, location: CGEventTapLocation?, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: @escaping () -> ()) -> Self {
        return self.add(mask: mask.rawValue, location: location, placement: placement, options: options, handler: handler)
    }
}