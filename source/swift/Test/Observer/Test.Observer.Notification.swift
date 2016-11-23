@testable import Observatory
import Nimble
import XCTest

open class NotificationObserverTestCase: XCTestCase
{
    open func test() {
        let center: NotificationCenter = NotificationCenter.default
        let observer: NotificationObserver = NotificationObserver(active: true)
        let observable: AnyObject = NSObject()

        var foo: Int = 0
        var bar: Int = 0

        try! observer.add(name: Notification.Name(rawValue: "foo"), observable: nil) { foo += 1 }
        try! observer.add(name: Notification.Name(rawValue: "bar"), observable: observable) { bar += 1 }

        // Foo will get caught on all objects, bar will only be caught on observable.

        center.post(name: Notification.Name(rawValue: "foo"), object: nil)
        center.post(name: Notification.Name(rawValue: "foo"), object: observable)
        center.post(name: Notification.Name(rawValue: "bar"), object: nil)
        center.post(name: Notification.Name(rawValue: "bar"), object: observable)

        expect(foo).to(equal(2))
        expect(bar).to(equal(1))

        // Deactivated observer must not catch anything.

        observer.active = false

        center.post(name: Notification.Name(rawValue: "foo"), object: observable)
        center.post(name: Notification.Name(rawValue: "bar"), object: observable)

        expect(foo).to(equal(2))
        expect(bar).to(equal(1))

        // Reactivated observer must work…

        observer.active = true

        center.post(name: Notification.Name(rawValue: "foo"), object: observable)
        center.post(name: Notification.Name(rawValue: "bar"), object: observable)

        expect(foo).to(equal(3))
        expect(bar).to(equal(2))
    }
}