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
            let layout = UCKeyboardLayout.data(for: "com.apple.keylayout.Ukrainian")
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
            let layout = UCKeyboardLayout.data(for: "com.apple.keylayout.Ukrainian")
            expect(layout).toNot(beNil())
            expect(KeyboardKey.a.name(layout: layout)) == "Ф"
        }

        it("can handle multi-threading") {
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 25
            for _ in 0 ..< 100 {
                queue.addOperation({
                    for _ in 0 ..< 1 {
                        autoreleasepool {
                            _ = KeyboardKey.a.name(layout: .ascii)
                            _ = KeyboardKey.escape.name(layout: .ascii)
                        }
                    }
                })
            }
            queue.waitUntilAllOperationsAreFinished()
        }

        it("can get layout data quickly") {
            let time = CFAbsoluteTimeGetCurrent()
            let iterationCount = 25_000
            for _ in 0 ..< iterationCount { autoreleasepool { _ = KeyboardKey.Layout.allCases.randomElement()!.data } }
            let duration = (CFAbsoluteTimeGetCurrent() - time) * 1000
            expect(duration) <= 500
            // Swift.print(String(format: "Getting layout data for \(iterationCount) times took %.3f ms.", duration))
        }
    }
}

extension UCKeyboardLayout {
    fileprivate static func data(for id: String) -> Data? {
        // Using properties filter to get the language doesn't work as expected and returns a different input… 🤔
        let inputSources = TISCreateInputSourceList(nil, true).takeRetainedValue() as? [TISInputSource]
        guard let inputSource = inputSources?.first(where: { unsafeBitCast(TISGetInputSourceProperty($0, kTISPropertyInputSourceID), to: CFString.self) as String == id }) else { return nil }
        guard let data = TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData)  else { return nil }
        guard let data = Unmanaged<AnyObject>.fromOpaque(data).takeUnretainedValue() as? NSData, data.count > 0 else { return nil }
        return Data(referencing: data)
    }
}
