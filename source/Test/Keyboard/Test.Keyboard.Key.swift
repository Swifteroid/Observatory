import Observatory
import Carbon
import Foundation
import Nimble
import XCTest

open class KeyboardKeyTestCase: XCTestCase
{
    open func testGetName() {
        expect(KeyboardKey.name(for: KeyboardKey.a)).to(equal("A"))
        expect(KeyboardKey.name(for: KeyboardKey.escape)).to(equal("⎋"))
    }
}