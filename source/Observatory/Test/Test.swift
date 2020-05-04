import Carbon
import Foundation
import Nimble
import Quick

internal class Spec: QuickSpec {

    /// This was something cool and used in some other testing, can't remember… Leaving as a reminder.
    private func sendHotkeyEvent(identifier: EventHotKeyID) {
        let eventHotKeyIdPointer: UnsafeMutablePointer<EventHotKeyID> = UnsafeMutablePointer.allocate(capacity: 1)
        eventHotKeyIdPointer.initialize(to: identifier)

        var eventPointer: OpaquePointer?
        CreateEvent(nil, UInt32(kEventClassKeyboard), UInt32(kEventHotKeyPressed), 0, 0, &eventPointer)
        SetEventParameter(eventPointer, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), MemoryLayout<EventHotKeyID>.size, eventHotKeyIdPointer)

        // We send event directly to our application target only.

        SendEventToEventTarget(eventPointer, GetApplicationEventTarget())
    }

    /// Posts a real hotkey event, make sure to not invoke dangerous hotkeys with it… ⚠️
    internal func postHotkeyEvent(key: CGKeyCode, flag: CGEventFlags) {
        let downEvent: CGEvent = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: true)!
        let upEvent: CGEvent = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: false)!
        downEvent.flags = flag
        upEvent.flags = flag

        downEvent.post(tap: CGEventTapLocation.cghidEventTap)
        upEvent.post(tap: CGEventTapLocation.cghidEventTap)

        var eventType: [EventTypeSpec] = [
            EventTypeSpec(eventClass: UInt32(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed)),
            EventTypeSpec(eventClass: UInt32(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyReleased)),
        ]

        var pointer: OpaquePointer?

        while ReceiveNextEvent(eventType.count, &eventType, 50 / 1000, true, &pointer) == Darwin.noErr {
            SendEventToEventTarget(pointer, GetApplicationEventTarget())
        }
    }
}
