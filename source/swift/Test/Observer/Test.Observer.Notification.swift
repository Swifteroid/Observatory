@testable import Observatory
import Nimble
import XCTest

public class NotificationObserverTestCase: XCTestCase
{
    public func test() {
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        let observer: NotificationObserver = NotificationObserver(active: true)
        let observable: AnyObject = NSObject()

        var foo: Int = 0
        var bar: Int = 0

        try! observer.add("foo", observable: nil) { foo += 1 }
        try! observer.add("bar", observable: observable) { bar += 1 }

        // Foo will get caught on all objects, bar will only be caught on observable.

        center.postNotificationName("foo", object: nil)
        center.postNotificationName("foo", object: observable)
        center.postNotificationName("bar", object: nil)
        center.postNotificationName("bar", object: observable)

        expect(foo).to(equal(2))
        expect(bar).to(equal(1))

        // Deactivated observer must not catch anything.

        observer.active = false

        center.postNotificationName("foo", object: observable)
        center.postNotificationName("bar", object: observable)

        expect(foo).to(equal(2))
        expect(bar).to(equal(1))

        // Reactivated observer must work…

        observer.active = true

        center.postNotificationName("foo", object: observable)
        center.postNotificationName("bar", object: observable)

        expect(foo).to(equal(3))
        expect(bar).to(equal(2))
    }
}