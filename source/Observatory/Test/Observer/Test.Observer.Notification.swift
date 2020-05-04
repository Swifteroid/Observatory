import Foundation
import Nimble
import Observatory
import Quick

internal class NotificationObserverSpec: Spec {
    override internal func spec() {
        it("can observe Foundation notifications in active state") {
            let center: NotificationCenter = NotificationCenter.default
            let observer: NotificationObserver = NotificationObserver(active: true)
            let observee: AnyObject = NSObject()
            let fooName: Notification.Name = .init("foo")
            let barName: Notification.Name = .init("bar")

            var foo: Int = 0
            var bar: Int = 0

            observer.add(name: fooName, observee: nil) { foo += 1 }
            observer.add(name: barName, observee: observee) { bar += 1 }

            // Foo will get caught on all objects, bar will only be caught on observable.

            center.post(name: fooName, object: nil)
            center.post(name: fooName, object: observee)
            center.post(name: barName, object: nil)
            center.post(name: barName, object: observee)

            expect(foo).to(equal(2))
            expect(bar).to(equal(1))

            // Deactivated observer must not catch anything.

            observer.isActive = false

            center.post(name: fooName, object: observee)
            center.post(name: barName, object: observee)

            expect(foo).to(equal(2))
            expect(bar).to(equal(1))

            // Reactivated observer must work…

            observer.isActive = true

            center.post(name: fooName, object: observee)
            center.post(name: barName, object: observee)

            expect(foo).to(equal(3))
            expect(bar).to(equal(2))
        }
    }

    private func readmeSample() {
        let observer: NotificationObserver = NotificationObserver(active: true)
        let observee: AnyObject = NSObject()

        observer
            .add(name: Notification.Name("foo"), observee: observee) { Swift.print("Foo captain!") }
            .add(names: [Notification.Name("bar"), Notification.Name("baz")], observee: observee) { Swift.print("Yes \($0.name)!") }
    }
}
