import Observatory
import Carbon
import Foundation
import Nimble
import XCTest

open class KeyboardKeyTestCase: XCTestCase
{
    open func testGetName() {
        expect(KeyboardKey.a.name).to(equal("A"))
        expect(KeyboardKey.escape.name).to(equal("⎋"))
    }
}