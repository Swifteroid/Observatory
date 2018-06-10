import Foundation
import Nimble
import Observatory
import Quick

internal class KeyboardKeySpec: Spec
{
    override internal func spec() {
        it("can return human-readable key name") {
            expect(KeyboardKey.a.name).to(equal("A"))
            expect(KeyboardKey.escape.name).to(equal("⎋"))
        }
    }
}