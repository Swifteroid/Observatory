import AppKit
import Carbon
import Foundation
import Nimble
import Observatory
import Quick

/// Wow, this turned out to be a serious pain in the ass – testing events is not a joke… Doing it properly requires running
/// a loop, as far as I understand there's no way testing global event dispatch, because, quoting, handler will not be called
/// for events that are sent to your own application. Instead, we check that observers sets everything up correctly.
internal class AppKitEventObserverSpec: Spec {
    override internal class func spec() {
        it("can observe events in active state") {
            let observer: EventObserver = EventObserver(active: true)

            observer.add(mask: NSEvent.EventTypeMask.any, handler: {})
            expect(observer.appKitDefinitions[0].handler.global) != nil
            expect(observer.appKitDefinitions[0].handler.local) != nil
            expect(observer.appKitDefinitions[0].monitor) != nil

            observer.add(mask: NSEvent.EventTypeMask.any, global: {})
            expect(observer.appKitDefinitions[1].handler.global) != nil
            expect(observer.appKitDefinitions[1].handler.local) == nil
            expect(observer.appKitDefinitions[1].monitor) != nil

            observer.add(mask: NSEvent.EventTypeMask.any, local: {})
            expect(observer.appKitDefinitions[2].handler.global) == nil
            expect(observer.appKitDefinitions[2].handler.local) != nil
            expect(observer.appKitDefinitions[2].monitor) != nil

            observer.isActive = false

            expect(observer.appKitDefinitions[0].monitor) == nil
            expect(observer.appKitDefinitions[1].monitor) == nil
            expect(observer.appKitDefinitions[2].monitor) == nil

            observer.isActive = true

            expect(observer.appKitDefinitions[0].monitor) != nil
            expect(observer.appKitDefinitions[1].monitor) != nil
            expect(observer.appKitDefinitions[2].monitor) != nil
        }
    }
}

internal class CarbonEventObserverSpec: Spec {
    override internal class func spec() {
        it("can observe events in active state") {
            let observer: EventObserver = EventObserver(active: true)
            let observation: Observation = Observation()

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
