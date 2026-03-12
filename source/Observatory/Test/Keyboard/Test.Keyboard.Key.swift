import Carbon
import Foundation
import Nimble
import Observatory
import Quick

internal class KeyboardKeySpec: Spec {
    override internal class func spec() {
        it("can init with string") {
            expect(KeyboardKey("")) == nil
            expect(KeyboardKey("…")) == nil
            expect(KeyboardKey("a")) == .a
            expect(KeyboardKey("A")) == .a
            expect(KeyboardKey("⎋")) == .escape
            expect(KeyboardKey("\u{001B}", layout: .ascii)) == .escape
            expect(KeyboardKey("Esc", custom: [.escape: "Esc"])) == .escape
        }

        it("can init with string in specified keyboard layout") {
            let layout = UCKeyboardLayout.data(for: "com.apple.keylayout.Ukrainian")
            expect(layout) != nil
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
            expect(layout) != nil
            expect(KeyboardKey.a.name(layout: layout)) == "Ф"
        }

        it("can handle multi-threading") {
            waitUntil(action: { done in
                let queue = OperationQueue()
                queue.maxConcurrentOperationCount = max(4, ProcessInfo.processInfo.activeProcessorCount * 2)

                // Stress-testing on main vs. background thread – this is what causes the failures. It appears TIS call must first originate
                // from the main thread, so it's placed on the main queue before layout data will attempt to call this. Note, under other
                // circumstances, this can / would be fine, so it's engineered as it is is on purpose.

                // To verify that this fails two things need to be done:
                //  - Disable caching inside Layout's data.
                //  - Disable main-thread calling inside Thread's mainly, or don't use mainly at all.

                for _ in 0 ..< 2500 {
                    queue.addOperation({
                        DispatchQueue.main.async {
                            autoreleasepool {
                                // This line seems to be the culprit on macOS Sequoia 15.7.2 (24G325) – without it, the test passes.
                                _ = TISCreateInputSourceList(nil, true).takeRetainedValue()
                                guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else { fatalError() }
                                guard TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) != nil else { fatalError() }
                            }
                        }

                        autoreleasepool {
                            // Without proper main-thread handling, this would crash…
                            expect(KeyboardKey.Layout.allCases.randomElement()!.data) != nil
                        }
                    })
                }

                queue.addBarrierBlock({ DispatchQueue.main.async(execute: done) })
            })
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
        guard let data = TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData) else { return nil }
        guard let data = Unmanaged<AnyObject>.fromOpaque(data).takeUnretainedValue() as? NSData, data.count > 0 else { return nil }
        return Data(referencing: data)
    }
}
