@testable import Observatory
import Carbon
import Foundation
import Nimble
import XCTest

public class KeyboardKeyTestCase: XCTestCase
{
    public func testGetName() {
        expect(KeyboardKey.getName((KeyboardKey.Escape))).to(equal("⎋"))
    }
}