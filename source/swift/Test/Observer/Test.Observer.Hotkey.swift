import Observatory
import Carbon
import Nimble
import XCTest

open class HotkeyObserverTestCase: XCTestCase
{
    open func test() {
        let observer: HotkeyObserver = try! HotkeyObserver(active: true)
        let modifier: CGEventFlags = CGEventFlags(rawValue: CGEventFlags.maskCommand.rawValue | CGEventFlags.maskShift.rawValue)
        let fooKey: CGKeyCode = CGKeyCode(KeyboardKey.five)
        let barKey: CGKeyCode = CGKeyCode(KeyboardKey.six)

        var foo: Int = 0
        var bar: Int = 0

        try! observer.add(hotkey: KeyboardHotkey(key: KeyboardKey.five, modifier: [KeyboardModifier.CommandKey, KeyboardModifier.ShiftKey])) { foo += 1 }
        try! observer.add(hotkey: KeyboardHotkey(key: KeyboardKey.six, modifier: [KeyboardModifier.CommandKey, KeyboardModifier.ShiftKey])) { bar += 1 }

        self.postHotkeyEvent(key: fooKey, flag: modifier)
        self.postHotkeyEvent(key: barKey, flag: modifier)

        expect(foo).to(equal(1))
        expect(bar).to(equal(1))

        // Deactivated observer must not catch anything.

        try! observer.deactivate()

        self.postHotkeyEvent(key: fooKey, flag: modifier)
        self.postHotkeyEvent(key: barKey, flag: modifier)

        expect(foo).to(equal(1))
        expect(bar).to(equal(1))

        // Reactivated observer must work…

        try! observer.activate()

        self.postHotkeyEvent(key: fooKey, flag: modifier)
        self.postHotkeyEvent(key: barKey, flag: modifier)

        expect(foo).to(equal(2))
        expect(bar).to(equal(2))

        // Removing must work.

        try! observer.remove(hotkey: KeyboardHotkey(key: KeyboardKey.five, modifier: [KeyboardModifier.CommandKey, KeyboardModifier.ShiftKey]))

        self.postHotkeyEvent(key: fooKey, flag: modifier)

        expect(foo).to(equal(2))
    }

    open func testError() {
        let observerFoo: HotkeyObserver = try! HotkeyObserver(active: true)
        let observerBar: HotkeyObserver = try! HotkeyObserver(active: true)
        let hotkey: KeyboardHotkey = KeyboardHotkey(key: KeyboardKey.five, modifier: [KeyboardModifier.CommandKey, KeyboardModifier.ShiftKey])

        // Todo: for some reason refuses to work when expect expression is wrapped in brackets, check in Swift 3.

        try! observerFoo.add(hotkey: hotkey, handler: {})
        expect { try observerBar.add(hotkey: hotkey, handler: {}) }.to(throwError(HotkeyObserverHandlerDefinition.Error.hotkeyAlreadyRegistered))
    }

    private func sendHotkeyEvent(identifier: EventHotKeyID) {
        let eventHotKeyIdPointer: UnsafeMutablePointer<EventHotKeyID> = UnsafeMutablePointer.allocate(capacity: 1)
        eventHotKeyIdPointer.initialize(to: identifier)

        var eventPointer: OpaquePointer? = nil
        CreateEvent(nil, UInt32(kEventClassKeyboard), UInt32(kEventHotKeyPressed), 0, 0, &eventPointer)
        SetEventParameter(eventPointer, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), MemoryLayout<EventHotKeyID>.size, eventHotKeyIdPointer)

        // We send event directly to our application target only.

        SendEventToEventTarget(eventPointer, GetApplicationEventTarget())
    }

    private func postHotkeyEvent(key: CGKeyCode, flag: CGEventFlags) {
        let downEvent: CGEvent = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: true)!
        let upEvent: CGEvent = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: false)!
        downEvent.flags = flag
        upEvent.flags = flag

        downEvent.post(tap: CGEventTapLocation.cghidEventTap)
        upEvent.post(tap: CGEventTapLocation.cghidEventTap)

        var eventType: [EventTypeSpec] = [
            EventTypeSpec(eventClass: UInt32(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed)),
            EventTypeSpec(eventClass: UInt32(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyReleased))
        ]

        var pointer: OpaquePointer? = nil

        while ReceiveNextEvent(eventType.count, &eventType, 50 / 1000, true, &pointer) == Darwin.noErr {
            SendEventToEventTarget(pointer, GetApplicationEventTarget())
        }
    }
}