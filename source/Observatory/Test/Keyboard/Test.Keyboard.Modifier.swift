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
    }
}
