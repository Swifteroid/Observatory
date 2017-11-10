import Observatory
import Carbon
import Nimble
import XCTest

open class HotkeyObserverTestCase: XCTestCase
{
    open func test() {
        let observer: HotkeyObserver = HotkeyObserver(active: true)
        let modifier: CGEventFlags = CGEventFlags(rawValue: CGEventFlags.maskCommand.rawValue | CGEventFlags.maskShift.rawValue)
        let fooKey: CGKeyCode = CGKeyCode(KeyboardKey.five)
        let barKey: CGKeyCode = CGKeyCode(KeyboardKey.six)

        var foo: Int = 0
        var bar: Int = 0

        observer.add(hotkey: KeyboardHotkey(key: KeyboardKey.five, modifier: [KeyboardModifier.commandKey, KeyboardModifier.shiftKey])) { foo += 1 }
        observer.add(hotkey: KeyboardHotkey(key: KeyboardKey.six, modifier: [KeyboardModifier.commandKey, KeyboardModifier.shiftKey])) { bar += 1 }

        self.postHotkeyEvent(key: fooKey, flag: modifier)
        self.postHotkeyEvent(key: barKey, flag: modifier)

        expect(foo).to(equal(1))
        expect(bar).to(equal(1))

        // Deactivated observer must not catch anything.

        observer.deactivate()

        self.postHotkeyEvent(key: fooKey, flag: modifier)
        self.postHotkeyEvent(key: barKey, flag: modifier)

        expect(foo).to(equal(1))
        expect(bar).to(equal(1))

        // Reactivated observer must work…

        observer.activate()

        self.postHotkeyEvent(key: fooKey, flag: modifier)
        self.postHotkeyEvent(key: barKey, flag: modifier)

        expect(foo).to(equal(2))
        expect(bar).to(equal(2))

        // Removing must work.

        observer.remove(hotkey: KeyboardHotkey(key: KeyboardKey.five, modifier: [KeyboardModifier.commandKey, KeyboardModifier.shiftKey]))

        self.postHotkeyEvent(key: fooKey, flag: modifier)

        expect(foo).to(equal(2))
    }

    open func testValidHotkeys() {
        let hotkeys: [KeyboardHotkey] = [
            KeyboardHotkey(key: KeyboardKey.a, modifier: []), // Apparently regular keys can be registered without modifiers.
            KeyboardHotkey(key: KeyboardKey.f5, modifier: []), // Function keys can be registered without modifiers.
            KeyboardHotkey(key: KeyboardKey.a, modifier: .commandKey),
            KeyboardHotkey(key: KeyboardKey.a, modifier: .optionKey),
            KeyboardHotkey(key: KeyboardKey.a, modifier: .controlKey)
        ]

        for hotkey in hotkeys {
            expect(expression: { HotkeyObserver(active: true).add(hotkey: hotkey, handler: {}) }).toNot(throwError())
        }
    }

    open func testInvalidHotkeys() {
        let hotkeys: [KeyboardHotkey] = [
            KeyboardHotkey(key: KeyboardKey.a, modifier: .capsLockKey), // Caps lock is not a valid modifier.
            KeyboardHotkey(key: KeyboardKey.a, modifier: [.capsLockKey, .controlKey]) // Or any combination.
        ]

        for hotkey in hotkeys {
            expect(HotkeyObserver(active: true).add(hotkey: hotkey, handler: {}).definitions.first?.error).toNot(beNil(), description: String(describing: hotkey))
        }
    }

    open func testError() {
        let observerFoo: HotkeyObserver = HotkeyObserver(active: true)
        let observerBar: HotkeyObserver = HotkeyObserver(active: true)
        let hotkey: KeyboardHotkey = KeyboardHotkey(key: KeyboardKey.five, modifier: [KeyboardModifier.commandKey, KeyboardModifier.shiftKey])

        observerFoo.add(hotkey: hotkey, handler: {})
        observerBar.add(hotkey: hotkey, handler: {})
        expect(observerBar.definitions.first?.error).toNot(beNil())
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

    private func readmeSample() {
        let observer: HotkeyObserver = HotkeyObserver(active: true)
        let fooHotkey: KeyboardHotkey = KeyboardHotkey(key: KeyboardKey.five, modifier: [.commandKey, .shiftKey])
        let barHotkey: KeyboardHotkey = KeyboardHotkey(key: KeyboardKey.six, modifier: [.commandKey, .shiftKey])

        observer
            .add(hotkey: fooHotkey) { Swift.print("Such foo…") }
            .add(hotkey: barHotkey) { Swift.print("So bar…") }
    }
}