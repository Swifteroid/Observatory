@testable import Observatory
import AppKit
import Carbon
import Foundation
import Nimble
import Quick

internal class AppKitEventObserverSpec: Spec {
    override internal class func spec() {
        typealias Definition = EventObserver.Handler.AppKit.Definition

        it("can activate and deactivate definitions") {
            let observer = EventObserver(active: false)
            let globalMonitoring = AppKitSpecMonitoring()
            let localMonitoring = AppKitSpecMonitoring()
            let globalDefinition = Definition(monitoring: globalMonitoring, mask: .any, handler: (global: { _ in }, local: nil))
            let localDefinition = Definition(monitoring: localMonitoring, mask: .any, handler: (global: nil, local: { event in event }))

            observer.add(definition: globalDefinition)
            observer.add(definition: localDefinition)
            expect(globalDefinition.monitor) == nil
            expect(localDefinition.monitor) == nil

            observer.activate()
            expect(globalMonitoring.count) == Count((local: 0, global: 1), 0)
            expect(localMonitoring.count) == Count((local: 1, global: 0), 0)
            expect(globalDefinition.monitor) != nil
            expect(localDefinition.monitor) != nil

            observer.activate() // Repetitive activation does nothing…
            expect(globalMonitoring.count) == Count((local: 0, global: 1), 0)
            expect(localMonitoring.count) == Count((local: 1, global: 0), 0)
            expect(globalDefinition.monitor) != nil
            expect(localDefinition.monitor) != nil

            observer.deactivate()
            expect(globalMonitoring.count) == Count((local: 0, global: 1), 1)
            expect(localMonitoring.count) == Count((local: 1, global: 0), 1)
            expect(globalDefinition.monitor) == nil
            expect(localDefinition.monitor) == nil

            observer.deactivate() // Repetitive deactivation does nothing…
            expect(globalMonitoring.count) == Count((local: 0, global: 1), 1)
            expect(localMonitoring.count) == Count((local: 1, global: 0), 1)
            expect(globalDefinition.monitor) == nil
            expect(localDefinition.monitor) == nil
        }

        it("can ignore callbacks when deactivated") {
            let monitoring = AppKitSpecMonitoring()
            let globalObservation = Observation()
            let localObservation = Observation()
            let definition = Definition(monitoring: monitoring, mask: .leftMouseDown, handler: (
                global: { _ in globalObservation.make() },
                local: { event in localObservation.make(); return event }
            ))

            definition.activate(true)

            let event = NSEvent.fake(type: .leftMouseDown)
            _ = monitoring.localHandler?(event)
            monitoring.globalHandler?(event)
            globalObservation.assert(count: 1)
            localObservation.assert(count: 1)

            definition.activate(false)
            let localResult = monitoring.localHandler?(event)
            monitoring.globalHandler?(event)

            expect(localResult === event) == true
            globalObservation.assert(count: 0)
            localObservation.assert(count: 0)
        }

        it("can deactivate on deinit") {
            let monitoring = AppKitSpecMonitoring()
            autoreleasepool {
                var definition: Definition? = Definition(monitoring: monitoring, mask: .any, handler: (global: { _ in }, local: { event in event }))
                definition?.activate(true)
                expect(monitoring.count) == .init((local: 1, global: 1), 0)
                definition = nil
            }
            expect(monitoring.count) == .init((local: 1, global: 1), 2)
        }

        it("can handle recursive activations and deactivations") {
            let monitoring = AppKitSpecMonitoring()
            let definition = Definition(monitoring: monitoring, mask: .appKitDefined, handler: (global: { _ in }, local: { event in event }))
            var observeReentryCount = 0
            var unobserveReentryCount = 0

            monitoring.observeCallback = {
                observeReentryCount += 1
                definition.activate(true)
            }

            monitoring.unobserveCallback = {
                unobserveReentryCount += 1
                definition.activate(false)
            }

            definition.activate(true)
            expect(definition.isActive) == true
            expect(definition.monitor) != nil
            expect(monitoring.count) == Count((local: 1, global: 1), 0)
            definition.activate(false)

            expect(observeReentryCount) == 2
            expect(unobserveReentryCount) == 2
            expect(monitoring.count) == Count((local: 1, global: 1), 2)
            expect(definition.isActive) == false
            expect(definition.monitor) == nil
        }

        it("can handle concurrent activations and deactivations") {
            let monitoring = AppKitSpecMonitoring()
            let definition = Definition(monitoring: monitoring, mask: .any, handler: (global: { _ in }, local: { event in event }))
            let queue = DispatchQueue(label: "\(Self.self).mixed.concurrent", attributes: .concurrent)
            let start = DispatchSemaphore(value: 0)
            let group = DispatchGroup()

            for index in 0..<16 {
                group.enter()
                queue.async {
                    start.wait()
                    definition.activate(index % 2 == 0)
                    group.leave()
                }
            }

            for _ in 0..<16 { start.signal() }
            group.wait()

            definition.activate(false)
            expect(definition.isActive) == false
            expect(definition.monitor) == nil
        }
    }

}

internal class CarbonEventObserverSpec: Spec {
    override internal class func spec() {
        it("can observe events in active state") {
            let observer = EventObserver(active: true)
            let observation = Observation()

            observer.add(mask: NSEvent.EventTypeMask.leftMouseDown.union(.rightMouseDown).rawValue, handler: { observation.make() })
            Event.postMouseEvent(type: CGEventType.leftMouseDown)
            Event.postMouseEvent(type: CGEventType.leftMouseUp)
            Event.postMouseEvent(type: CGEventType.rightMouseDown)
            Event.postMouseEvent(type: CGEventType.rightMouseUp)
            observation.assert(count: 2)

            observer.isActive = false
            Event.postMouseEvent(type: CGEventType.leftMouseDown)
            Event.postMouseEvent(type: CGEventType.leftMouseUp)
            observation.assert(count: 0)
        }
    }
}

fileprivate struct Count: Equatable {
    fileprivate init(_ observe: (local: Int, global: Int) = (0, 0), _ unobserve: Int = 0) {
        self.observe = observe
        self.unobserve = unobserve
    }
    fileprivate var observe: (local: Int, global: Int) = (0, 0)
    fileprivate var unobserve: Int = 0
    fileprivate static func == (lhs: Count, rhs: Count) -> Bool { lhs.observe == rhs.observe && lhs.unobserve == rhs.unobserve }
}

private final class AppKitSpecMonitoring: EventObserver.Handler.AppKit.Definition.Monitoring {
    internal var count: Count = Count()

    internal var globalHandler: ((NSEvent) -> Void)?
    internal var localHandler: ((NSEvent) -> NSEvent?)?
    internal var observeCallback: (() -> Void)?
    internal var unobserveCallback: (() -> Void)?

    override internal func observe(global mask: NSEvent.EventTypeMask, _ handler: @escaping (NSEvent) -> Void) -> Any? {
        self.count.observe.global += 1
        self.globalHandler = handler
        self.observeCallback?()
        return NSObject()
    }

    override internal func observe(local mask: NSEvent.EventTypeMask, _ handler: @escaping (NSEvent) -> NSEvent?) -> Any? {
        self.count.observe.local += 1
        self.localHandler = handler
        self.observeCallback?()
        return NSObject()
    }

    override internal func unobserve(_ monitor: Any) {
        self.count.unobserve += 1
        self.unobserveCallback?()
    }
}

extension NSEvent {
    fileprivate static func fake(type: CGEventType) -> NSEvent {
        guard let event = CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: CGPoint(x: -10000, y: -10000), mouseButton: .center) else { preconditionFailure("Cannot construct fake CGEvent.") }
        guard let event = NSEvent(cgEvent: event) else { preconditionFailure("Cannot construct fake NSEvent.") }
        return event
    }
}
