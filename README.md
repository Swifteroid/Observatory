# Observatory

Observatory is a micro-framework for easier event, notification and hotkey management in Swift.

- Standardised approach for event, notification and hotkey observing.
- Simple enabling and disabling of observers.
- Rich choice of handler signatures.
- Handle local / global / both events.
- Chaining support.

Observe global hotkeys.

```swift
let observer: HotkeyObserver = HotkeyObserver(active: true)
let fooHotkey: KeyboardHotkey = KeyboardHotkey(key: KeyboardKey.Five, modifier: [KeyboardModifier.CmdKey, KeyboardModifier.ShiftKey])
let barHotkey: KeyboardHotkey = KeyboardHotkey(key: KeyboardKey.Six, modifier: [KeyboardModifier.CmdKey, KeyboardModifier.ShiftKey])

try! observer
    .add(fooHotkey) { Swift.print("Such foo…") }
    .add(barHotkey) { Swift.print("So bar…") }
```

Observe notifications, chose between plain `() -> ()` or standard `(NSNotification) -> ()` signatures.

```swift
let observer: NotificationObserver = NotificationObserver(active: true)
let observable: AnyObject = NSObject()

try! observer
    .add("foo", observable: observable) { Swift.print("Foo captain!") }
    .add(["bar", "baz"], observable: observable) { (notification: NSNotification) in Swift.print("Yes \(notification.name)!") }
```

Observe events, like with notifications, you can chose between plain `() -> ()` and standard local `(NSEvent) -> NSEvent?` or global `(NSEvent) -> ()` signatures.

```swift
let observer: EventObserver = EventObserver(active: true)

try! observer
    .add(NSEventMask.AnyEventMask, observable: observable) { Swift.print("Any is better than none.") }
    .add([NSEventMask.LeftMouseDownMask, NSEventMask.LeftMouseUpMask], observable: observable) { (event: NSEvent) in Swift.print("It's a mouse!") }
```

Checkout `Observatory.playground` for information and examples.
