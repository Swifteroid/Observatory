/*:
 > **To use the playground make sure to open it from within `Observatory.xcworkspace` and 
 > build the `Observatory` scheme first, results will appear the debug area.**
 */

import Foundation
import Observatory

let center: NotificationCenter = NotificationCenter.default
let queue: OperationQueue = OperationQueue()
let observable: NSObject = NSObject()

/*:
 By default observer is not activated, you can activate it with initialiser or 
 by setting `active` property. 
 */

var observer: NotificationObserver? = NotificationObserver(active: true)

/*:
 Adding handlers for notifications is nearly the same as with the notification 
 center, but gives more options and flexibility – can add multiple notifications in one 
 go, can omit `notification` parameter in the callback, can use chaining, etc.
 */

try! observer!
    .add(name: Notification.Name(rawValue: "foo"), observable: observable) { Swift.print("foo") }
    .add(names: [Notification.Name(rawValue: "bar"), Notification.Name(rawValue: "baz")], observable: observable) { (notification: Notification) in Swift.print(notification.name) }

center.post(name: Notification.Name(rawValue: "foo"), object: observable)
center.post(name: Notification.Name(rawValue: "bar"), object: observable)
center.post(name: Notification.Name(rawValue: "baz"), object: observable)

/*:
 When the observer is no longer needed it can be deactivated and reactivated later, this is
 handy when, for example, observer must be active only when the view is visible.
 */

observer!.active = false

/*:
 Handlers can be removed on more than one way – all by notification name, all by observable 
 object or using a combinations.
 */

observer!.remove(name: Notification.Name(rawValue: "foo"))
observer!.remove(name: Notification.Name(rawValue: "bar"), observable: observable)
observer!.remove(observable)

/*:
 If the observer is no longer needed it can be simply dismissed. It will automatically deactivate
 and remove all handlers, so you don't have to worry about that.
 */

observer = nil
