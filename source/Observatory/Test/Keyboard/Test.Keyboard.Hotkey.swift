import Foundation
import Nimble
import Observatory
import Quick

internal class KeyboardHotkeySpec: Spec {
    override internal class func spec() {
        it("must correctly initialise with raw value") {
            let hotkeyFoo: KeyboardHotkey = KeyboardHotkey(key: KeyboardKey.a, modifier: KeyboardModifier.commandKey)
            let hotkeyBar: KeyboardHotkey = KeyboardHotkey(rawValue: hotkeyFoo.rawValue)
            expect(hotkeyFoo).to(equal(hotkeyBar))
        }

        it("can return name in specified keyboard layout") {
            expect(KeyboardHotkey(key: .six, modifier: [.commandKey, .shiftKey]).name(layout: .neutral)) == "⇧⌘6"
            expect(KeyboardHotkey(key: .escape, modifier: .commandKey).name(layout: .neutral)) == "⌘⎋"
        }
    }
}
