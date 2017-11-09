import Foundation
import Carbon

/// Event observer provides a flexible interface for registering and managing multiple event handlers in, both, global
/// and local contexts.

open class EventObserver: Observer
{
    open internal(set) var carbonDefinitions: [CarbonEventObserverHandlerDefinition] = []
    open internal(set) var appKitDefinitions: [AppKitEventObserverHandlerDefinition] = []

    // MARK: -

    public convenience init(active: Bool) {
        self.init()
        self.activate(active)
    }

    // MARK: -

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

    // MARK: -

    @discardableResult open func add(mask: NSEvent.EventTypeMask, global: Bool, local: Bool, handler: Any) throws -> Self {
        let factory: AppKitEventObserverHandlerDefinitionFactory = AppKitEventObserverHandlerDefinitionFactory(
            mask: mask,
            global: global,
            local: local,
            handler: handler
        )

        let definition: AppKitEventObserverHandlerDefinition = try factory.construct()

        guard !self.appKitDefinitions.contains(definition) else { return self }
        self.appKitDefinitions.append(self.active ? definition.activate() : definition)

        return self
    }

    @discardableResult open func add(mask: NSEvent.EventTypeMask, handler: Any) throws -> Self {
        return try self.add(mask: mask, global: true, local: true, handler: handler)
    }

    @discardableResult open func add(mask: CGEventMask, location: CGEventTapLocation? = nil, placement: CGEventTapPlacement? = nil, options: CGEventTapOptions? = nil, handler: Any) throws -> Self {
        let factory: CarbonEventObserverHandlerDefinitionFactory = CarbonEventObserverHandlerDefinitionFactory(
            mask: mask,
            location: location ?? CGEventTapLocation.cgSessionEventTap,
            placement: placement ?? CGEventTapPlacement.headInsertEventTap,
            options: options ?? CGEventTapOptions.defaultTap,
            handler: handler
        )

        let definition: CarbonEventObserverHandlerDefinition = try factory.construct()

        guard !self.carbonDefinitions.contains(definition) else { return self }
        self.carbonDefinitions.append(self.active ? definition.activate() : definition)

        return self
    }

    @discardableResult open func remove(mask: NSEvent.EventTypeMask, handler: Any?, strict: Bool) -> Self {
        for (index, _) in self.filter(mask: mask, handler: handler, strict: strict).reversed() {
            self.appKitDefinitions.remove(at: index)
        }

        return self
    }

    @discardableResult open func remove(mask: NSEvent.EventTypeMask, handler: Any?) -> Self {
        return self.remove(mask: mask, handler: handler, strict: false)
    }

    @discardableResult open func remove(mask: NSEvent.EventTypeMask) -> Self {
        return self.remove(mask: mask, handler: nil, strict: false)
    }

    // MARK: -

    private func filter(mask: NSEvent.EventTypeMask, handler: Any?, strict: Bool) -> [(offset: Int, element: AppKitEventObserverHandlerDefinition)] {
        return self.appKitDefinitions.enumerated().filter({ (_: Int, definition: AppKitEventObserverHandlerDefinition) in
            return true &&
                (mask == definition.mask) &&
                (handler == nil && !strict || handler != nil && type(of: self).compareBlocks(definition.handler.original, handler!))
        })
    }

    // MARK: -

    override open class func compareBlocks(_ lhs: Any, _ rhs: Any) -> Bool {
        if lhs is AppKitEventObserverConventionHandler.Global && rhs is AppKitEventObserverConventionHandler.Global {
            return unsafeBitCast(lhs as! AppKitEventObserverConventionHandler.Global, to: AnyObject.self) === unsafeBitCast(rhs as! AppKitEventObserverConventionHandler.Global, to: AnyObject.self)
        } else if lhs is AppKitEventObserverConventionHandler.Local && rhs is AppKitEventObserverConventionHandler.Local {
            return unsafeBitCast(lhs as! AppKitEventObserverConventionHandler.Local, to: AnyObject.self) === unsafeBitCast(rhs as! AppKitEventObserverConventionHandler.Local, to: AnyObject.self)
        } else {
            return Observer.compareBlocks(lhs, rhs)
        }
    }
}