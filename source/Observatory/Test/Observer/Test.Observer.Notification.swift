import Observatory
import Nimble
import XCTest

open class NotificationObserverTestCase: XCTestCase
{
    open func test() {
        let center: NotificationCenter = NotificationCenter.default
        let observer: NotificationObserver = NotificationObserver(active: true)
        let observee: AnyObject = NSObject()

        var foo: Int = 0
        var bar: Int = 0

        observer.add(name: Notification.Name("foo"), observee: nil) { foo += 1 }
        observer.add(name: Notification.Name("bar"), observee: observee) { bar += 1 }

        // Foo will get caught on all objects, bar will only be caught on observable.

        center.post(name: Notification.Name("foo"), object: nil)
        center.post(name: Notification.Name("foo"), object: observee)
        center.post(name: Notification.Name("bar"), object: nil)
        center.post(name: Notification.Name("bar"), object: observee)

        expect(foo).to(equal(2))
        expect(bar).to(equal(1))

        // Deactivated observer must not catch anything.

        observer.active = false

        center.post(name: Notification.Name("foo"), object: observee)
        center.post(name: Notification.Name("bar"), object: observee)

        expect(foo).to(equal(2))
        expect(bar).to(equal(1))

        // Reactivated observer must work…

        observer.active = true

        center.post(name: Notification.Name("foo"), object: observee)
        center.post(name: Notification.Name("bar"), object: observee)

        expect(foo).to(equal(3))
        expect(bar).to(equal(2))
    }

    private func readmeSample() {
        let observer: NotificationObserver = NotificationObserver(active: true)
        let observee: AnyObject = NSObject()

        observer
            .add(name: Notification.Name("foo"), observee: observee) { Swift.print("Foo captain!") }
            .add(names: [Notification.Name("bar"), Notification.Name("baz")], observee: observee) { Swift.print("Yes \($0.name)!") }
    }
}