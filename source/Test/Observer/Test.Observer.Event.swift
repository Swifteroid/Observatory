import Observatory
import Carbon
import Nimble
import XCTest

/*
Wow, this turned out to be a serious pain in the ass – testing events is not a joke… Doing it properly requires running 
a loop, as far as I understand there's no way testing global event dispatch, because, quoting, handler will not be called
for events that are sent to your own application. Instead, we check that observers sets everything up correctly.
*/
internal class EventObserverTestCase: XCTestCase
{
    internal func testAppKit() {
        let observer: EventObserver = EventObserver(active: true)

        try! observer.add(mask: NSEventMask.any, global: true, local: true, handler: {})
        expect(observer.appKitDefinitions[0].handler.global).toNot(beNil())
        expect(observer.appKitDefinitions[0].handler.local).toNot(beNil())
        expect(observer.appKitDefinitions[0].monitor).toNot(beNil())

        try! observer.add(mask: NSEventMask.any, global: true, local: false, handler: {})
        expect(observer.appKitDefinitions[1].handler.global).toNot(beNil())
        expect(observer.appKitDefinitions[1].handler.local).to(beNil())
        expect(observer.appKitDefinitions[1].monitor).toNot(beNil())

        try! observer.add(mask: NSEventMask.any, global: false, local: true, handler: {})
        expect(observer.appKitDefinitions[2].handler.global).to(beNil())
        expect(observer.appKitDefinitions[2].handler.local).toNot(beNil())
        expect(observer.appKitDefinitions[2].monitor).toNot(beNil())

        try! observer.add(mask: NSEventMask.any, handler: {})
        expect(observer.appKitDefinitions[3].handler.global).toNot(beNil())
        expect(observer.appKitDefinitions[3].handler.local).toNot(beNil())
        expect(observer.appKitDefinitions[3].monitor).toNot(beNil())

        observer.active = false

        expect(observer.appKitDefinitions[0].monitor).to(beNil())
        expect(observer.appKitDefinitions[1].monitor).to(beNil())
        expect(observer.appKitDefinitions[2].monitor).to(beNil())
        expect(observer.appKitDefinitions[3].monitor).to(beNil())

        observer.active = true

        expect(observer.appKitDefinitions[0].monitor).toNot(beNil())
        expect(observer.appKitDefinitions[1].monitor).toNot(beNil())
        expect(observer.appKitDefinitions[2].monitor).toNot(beNil())
        expect(observer.appKitDefinitions[3].monitor).toNot(beNil())
    }

    internal func testCarbon() {
        let observer: EventObserver = EventObserver(active: true)
        let observation: Observation = Observation()

        try! observer.add(mask: NSEventMask([NSEventMask.leftMouseDown, NSEventMask.rightMouseDown]).rawValue, handler: { observation.make() })
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