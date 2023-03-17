import Carbon
import Foundation
import Nimble
import Observatory
import Quick

internal class KeyboardKeySpec: Spec {
    override internal func spec() {
        it("can return human-readable key name") {
            expect(KeyboardKey.a.name).to(equal("A"))
            expect(KeyboardKey.a.name(layout: .ascii)).to(equal("A"))
            expect(KeyboardKey.escape.name).to(equal("⎋"))
            expect(KeyboardKey.escape.name(map: [.escape: "Esc"])).to(equal("Esc"))
        }

        it("can return key name in specified keyboard layout") {
            // Using properties filter to get the language doesn't work as expected and returns a different input… 🤔
            let inputSources = TISCreateInputSourceList(nil, true).takeRetainedValue() as? [TISInputSource]
            let inputSource = inputSources?.first(where: { unsafeBitCast(TISGetInputSourceProperty($0, kTISPropertyInputSourceID), to: CFString.self) as String == "com.apple.keylayout.Ukrainian" })
            let layoutData = inputSource.map({ unsafeBitCast(TISGetInputSourceProperty($0, kTISPropertyUnicodeKeyLayoutData), to: CFData.self) as NSData })
            let layout = layoutData.map({ $0.bytes.bindMemory(to: UCKeyboardLayout.self, capacity: $0.length) })
            expect(layout).toNot(beNil())
            expect(KeyboardKey.a.name(layout: layout)) == "Ф"
        }
    }
}
