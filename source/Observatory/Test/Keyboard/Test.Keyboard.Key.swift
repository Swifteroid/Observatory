import Carbon
import Foundation
import Nimble
import Observatory
import Quick

internal class KeyboardKeySpec: Spec {
    override internal func spec() {
        it("can init with string") {
            expect(KeyboardKey("")).to(beNil())
            expect(KeyboardKey("…")).to(beNil())
            expect(KeyboardKey("a")) == .a
            expect(KeyboardKey("A")) == .a
            expect(KeyboardKey("⎋")) == .escape
            expect(KeyboardKey("\u{001B}", layout: .ascii)) == .escape
            expect(KeyboardKey("Esc", custom: [.escape: "Esc"])) == .escape
        }

        it("can init with string in specified keyboard layout") {
            let layout = UCKeyboardLayout.for(id: "com.apple.keylayout.Ukrainian")
            expect(layout).toNot(beNil())
            expect(KeyboardKey("ф", layout: layout)) == .a
            expect(KeyboardKey("Ф", layout: layout)) == .a
        }

        it("can return human-readable key name") {
            expect(KeyboardKey.a.name) == "A"
            expect(KeyboardKey.a.name(layout: .ascii)) == "A"
            expect(KeyboardKey.escape.name) == "⎋"
            expect(KeyboardKey.escape.name(layout: .ascii)) == "\u{001B}"
            expect(KeyboardKey.escape.name(custom: [.escape: "Esc"])) == "Esc"
        }

        it("can return key name in specified keyboard layout") {
            let layout = UCKeyboardLayout.for(id: "com.apple.keylayout.Ukrainian")
            expect(layout).toNot(beNil())
            expect(KeyboardKey.a.name(layout: layout)) == "Ф"
        }
    }
}

extension UCKeyboardLayout {
    fileprivate static func `for`(id: String) -> UnsafePointer<Self>? {
        // Using properties filter to get the language doesn't work as expected and returns a different input… 🤔
        let inputSources = TISCreateInputSourceList(nil, true).takeRetainedValue() as? [TISInputSource]
        let inputSource = inputSources?.first(where: { unsafeBitCast(TISGetInputSourceProperty($0, kTISPropertyInputSourceID), to: CFString.self) as String == id })
        let layoutData = inputSource.map({ unsafeBitCast(TISGetInputSourceProperty($0, kTISPropertyUnicodeKeyLayoutData), to: CFData.self) as NSData })
        return layoutData.map({ $0.bytes.bindMemory(to: self, capacity: $0.length) })
    }
}
