import Foundation
import Nimble
import Observatory
import Quick

internal class KeyboardHotkeySpec: Spec
{
    override internal func spec() {
        it("must correctly initialise with raw value") {
            let hotkeyFoo: KeyboardHotkey = KeyboardHotkey(key: KeyboardKey.a, modifier: KeyboardModifier.commandKey)
            let hotkeyBar: KeyboardHotkey = KeyboardHotkey(rawValue: hotkeyFoo.rawValue)
            expect(hotkeyFoo).to(equal(hotkeyBar))
        }
    }
}