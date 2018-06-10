import Carbon
import Foundation
import Nimble
import Observatory
import Quick

/// Wow, this turned out to be a serious pain in the ass – testing events is not a joke… Doing it properly requires running 
/// a loop, as far as I understand there's no way testing global event dispatch, because, quoting, handler will not be called
/// for events that are sent to your own application. Instead, we check that observers sets everything up correctly.
internal class EventObserverSpec: Spec
{
    override internal func spec() {
        it("can observe AppKit events in active state") {
            let observer: EventObserver = EventObserver(active: true)

            observer.add(mask: NSEvent.EventTypeMask.any, handler: {})
            expect(observer.appKitDefinitions[0].handler.global).toNot(beNil())
            expect(observer.appKitDefinitions[0].handler.local).toNot(beNil())
            expect(observer.appKitDefinitions[0].monitor).toNot(beNil())

            observer.add(mask: NSEvent.EventTypeMask.any, global: {})
            expect(observer.appKitDefinitions[1].handler.global).toNot(beNil())
            expect(observer.appKitDefinitions[1].handler.local).to(beNil())
            expect(observer.appKitDefinitions[1].monitor).toNot(beNil())

            observer.add(mask: NSEvent.EventTypeMask.any, local: {})
            expect(observer.appKitDefinitions[2].handler.global).to(beNil())
            expect(observer.appKitDefinitions[2].handler.local).toNot(beNil())
            expect(observer.appKitDefinitions[2].monitor).toNot(beNil())

            observer.active = false

            expect(observer.appKitDefinitions[0].monitor).to(beNil())
            expect(observer.appKitDefinitions[1].monitor).to(beNil())
            expect(observer.appKitDefinitions[2].monitor).to(beNil())

            observer.active = true

            expect(observer.appKitDefinitions[0].monitor).toNot(beNil())
            expect(observer.appKitDefinitions[1].monitor).toNot(beNil())
            expect(observer.appKitDefinitions[2].monitor).toNot(beNil())
        }

        it("can observe Carbon events in active state") {
            let observer: EventObserver = EventObserver(active: true)
            let observation: Observation = Observation()

            observer.add(mask: NSEvent.EventTypeMask.leftMouseDown.union(.rightMouseDown).rawValue, handler: { observation.make() })
            Event.postMouseEvent(type: CGEventType.leftMouseDown)
            Event.postMouseEvent(type: CGEventType.leftMouseUp)
            Event.postMouseEvent(type: CGEventType.rightMouseDown)
            Event.postMouseEvent(type: CGEventType.rightMouseUp)
            observation.assert(count: 2)

            observer.active = false
            Event.postMouseEvent(type: CGEventType.leftMouseDown)
            Event.postMouseEvent(type: CGEventType.leftMouseUp)
            observation.assert(count: 0)
        }
    }

    private func readmeSample() {
        let observer: EventObserver = EventObserver(active: true)

        observer
            .add(mask: .any, handler: { Swift.print("Any is better than none.") })
            .add(mask: [.leftMouseDown, .leftMouseUp], handler: { Swift.print("It's a \($0.type) event!") })
    }
}