import Observatory
import Foundation
import Nimble
import XCTest

open class KeyboardHotkeyTestCase: XCTestCase
{
    open func test() {
        let hotkeyFoo: KeyboardHotkey = KeyboardHotkey(key: KeyboardKey.A, modifier: KeyboardModifier.CommandKey)
        let hotkeyBar: KeyboardHotkey = KeyboardHotkey(value: hotkeyFoo.value)
        expect(hotkeyFoo).to(equal(hotkeyBar))
    }
}