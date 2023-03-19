import AppKit
import CoreGraphics
import Foundation
import Nimble
import Observatory
import Quick

internal class KeyboardModifierSpec: Spec {
    override internal func spec() {
        it("can return keys") {
            expect(KeyboardModifier.capsLockKey.keys) == [.capsLock]
            expect(KeyboardModifier.commandKey.keys) == [.command]
            expect(KeyboardModifier.controlKey.keys) == [.control]
            expect(KeyboardModifier.optionKey.keys) == [.option]
            expect(KeyboardModifier.shiftKey.keys) == [.shift]
        }

        it("can return name") {
            expect(KeyboardModifier.capsLockKey.name) == "⇪"
            expect(KeyboardModifier.commandKey.name) == "⌘"
            expect(KeyboardModifier.controlKey.name) == "⌃"
            expect(KeyboardModifier.optionKey.name) == "⌥"
            expect(KeyboardModifier.shiftKey.name) == "⇧"
        }

        it("should return keys and name in correct order") {
            let modifier: KeyboardModifier = [.capsLockKey, .commandKey, .controlKey, .optionKey, .shiftKey]
            expect(modifier.keys) == [.control, .option, .capsLock, .shift, .command]
            expect(modifier.name) == "⌃⌥⇪⇧⌘"
        }

        it("can convert into CGEventFlags") {
            expect(CGEventFlags(modifier: KeyboardModifier.capsLockKey)) == .maskAlphaShift
            expect(CGEventFlags(modifier: KeyboardModifier.commandKey)) == .maskCommand
            expect(CGEventFlags(modifier: KeyboardModifier.controlKey)) == .maskControl
            expect(CGEventFlags(modifier: KeyboardModifier.optionKey)) == .maskAlternate
            expect(CGEventFlags(modifier: KeyboardModifier.shiftKey)) == .maskShift
            let modifier: KeyboardModifier = [.capsLockKey, .commandKey, .controlKey, .optionKey, .shiftKey]
            expect(CGEventFlags(modifier: modifier)) == [.maskAlphaShift, .maskCommand, .maskControl, .maskAlternate, .maskShift]
        }

        it("can convert into NSEvent.ModifierFlags") {
            expect(NSEvent.ModifierFlags(modifier: KeyboardModifier.capsLockKey)) == .capsLock
            expect(NSEvent.ModifierFlags(modifier: KeyboardModifier.commandKey)) == .command
            expect(NSEvent.ModifierFlags(modifier: KeyboardModifier.controlKey)) == .control
            expect(NSEvent.ModifierFlags(modifier: KeyboardModifier.optionKey)) == .option
            expect(NSEvent.ModifierFlags(modifier: KeyboardModifier.shiftKey)) == .shift
            let modifier: KeyboardModifier = [.capsLockKey, .commandKey, .controlKey, .optionKey, .shiftKey]
            expect(NSEvent.ModifierFlags(modifier: modifier)) == [.capsLock, .command, .control, .option, .shift]
        }
    }
}
