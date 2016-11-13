@testable import Observatory
import Carbon
import Nimble
import XCTest

public class HotkeyObserverTestCase: XCTestCase
{
    public func test() {
        let observer: HotkeyObserver = HotkeyObserver(active: true)
        let modifier: CGEventFlags = CGEventFlags(rawValue: CGEventFlags.MaskCommand.rawValue | CGEventFlags.MaskShift.rawValue)!
        let fooKey: CGKeyCode = CGKeyCode(KeyboardKey.Five)
        let barKey: CGKeyCode = CGKeyCode(KeyboardKey.Six)

        var foo: Int = 0
        var bar: Int = 0

        try! observer.add(KeyboardHotkey(key: KeyboardKey.Five, modifier: [KeyboardModifier.CommandKey, KeyboardModifier.ShiftKey])) { foo += 1 }
        try! observer.add(KeyboardHotkey(key: KeyboardKey.Six, modifier: [KeyboardModifier.CommandKey, KeyboardModifier.ShiftKey])) { bar += 1 }

        self.postHotKeyEvent(fooKey, flag: modifier)
        self.postHotKeyEvent(barKey, flag: modifier)

        expect(foo).to(equal(1))
        expect(bar).to(equal(1))

        // Deactivated observer must not catch anything.

        observer.active = false

        self.postHotKeyEvent(fooKey, flag: modifier)
        self.postHotKeyEvent(barKey, flag: modifier)

        expect(foo).to(equal(1))
        expect(bar).to(equal(1))

        // Reactivated observer must work…

        observer.active = true

        self.postHotKeyEvent(fooKey, flag: modifier)
        self.postHotKeyEvent(barKey, flag: modifier)

        expect(foo).to(equal(2))
        expect(bar).to(equal(2))

        // Removing must work.

        observer.remove(KeyboardHotkey(key: KeyboardKey.Five, modifier: [KeyboardModifier.CommandKey, KeyboardModifier.ShiftKey]))

        self.postHotKeyEvent(fooKey, flag: modifier)

        expect(foo).to(equal(2))
    }

    private func sendHotKeyEvent(identifier: EventHotKeyID) {
        let eventHotKeyIdPointer: UnsafeMutablePointer<EventHotKeyID> = UnsafeMutablePointer.alloc(1)
        eventHotKeyIdPointer.initialize(identifier)

        var eventPointer: COpaquePointer = nil
        CreateEvent(nil, UInt32(kEventClassKeyboard), UInt32(kEventHotKeyPressed), 0, 0, &eventPointer)
        SetEventParameter(eventPointer, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), sizeof(EventHotKeyID), eventHotKeyIdPointer)

        // We send event directly to it to our application target only.

        SendEventToEventTarget(eventPointer, GetApplicationEventTarget())
    }

    private func postHotKeyEvent(key: CGKeyCode, flag: CGEventFlags) {
        let downEvent: CGEvent = CGEventCreateKeyboardEvent(nil, key, true)!
        let upEvent: CGEvent = CGEventCreateKeyboardEvent(nil, key, false)!
        CGEventSetFlags(downEvent, flag)
        CGEventSetFlags(upEvent, flag)

        CGEventPost(CGEventTapLocation.CGHIDEventTap, downEvent)
        CGEventPost(CGEventTapLocation.CGHIDEventTap, upEvent)

        var eventType: [EventTypeSpec] = [
            EventTypeSpec(eventClass: UInt32(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed)),
            EventTypeSpec(eventClass: UInt32(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyReleased))
        ]

        var pointer: COpaquePointer = nil

        while ReceiveNextEvent(eventType.count, &eventType, 50 / 1000, true, &pointer) == Darwin.noErr {
            SendEventToEventTarget(pointer, GetApplicationEventTarget())
        }
    }
}