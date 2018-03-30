import Observatory
import Foundation
import Nimble
import XCTest

open class KeyboardHotkeyTestCase: XCTestCase
{
    open func test() {
        let hotkeyFoo: KeyboardHotkey = KeyboardHotkey(key: KeyboardKey.a, modifier: KeyboardModifier.commandKey)
        let hotkeyBar: KeyboardHotkey = KeyboardHotkey(rawValue: hotkeyFoo.rawValue)
        expect(hotkeyFoo).to(equal(hotkeyBar))
    }
}