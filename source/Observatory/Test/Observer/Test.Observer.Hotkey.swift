import Carbon
import Foundation
import Nimble
import Observatory
import Quick

internal class HotkeyObserverSpec: Spec
{
    override internal func spec() {
        it("can observe hotkeys in active state") {
            let observer: HotkeyObserver = HotkeyObserver(active: true)
            let modifier: CGEventFlags = [.maskCommand, .maskShift]
            let fooKey: CGKeyCode = CGKeyCode(KeyboardKey.five.rawValue)
            let barKey: CGKeyCode = CGKeyCode(KeyboardKey.six.rawValue)

            var foo: Int = 0
            var bar: Int = 0

            expect(observer.isActive) == true

            observer.add(hotkey: KeyboardHotkey(key: .five, modifier: [.commandKey, .shiftKey])) { foo += 1 }
            observer.add(hotkey: KeyboardHotkey(key: .six, modifier: [.commandKey, .shiftKey])) { bar += 1 }

            self.postHotkeyEvent(key: fooKey, flag: modifier)
            self.postHotkeyEvent(key: barKey, flag: modifier)

            expect(foo).to(equal(1))
            expect(bar).to(equal(1))

            // Deactivated observer must not catch anything.

            observer.deactivate()
            expect(observer.isActive) == false

            self.postHotkeyEvent(key: fooKey, flag: modifier)
            self.postHotkeyEvent(key: barKey, flag: modifier)

            expect(foo).to(equal(1))
            expect(bar).to(equal(1))

            // Reactivated observer must work…

            observer.activate()
            expect(observer.isActive) == true

            self.postHotkeyEvent(key: fooKey, flag: modifier)
            self.postHotkeyEvent(key: barKey, flag: modifier)

            expect(foo).to(equal(2))
            expect(bar).to(equal(2))

            // Removing must work.

            observer.remove(hotkey: KeyboardHotkey(key: .five, modifier: [.commandKey, .shiftKey]))

            self.postHotkeyEvent(key: fooKey, flag: modifier)

            expect(foo).to(equal(2))
        }

        it("must not produce definition error when adding valid hotkey observation") {
            let hotkeys: [KeyboardHotkey] = [
                KeyboardHotkey(key: KeyboardKey.a, modifier: []), // Apparently regular keys can be registered without modifiers.
                KeyboardHotkey(key: KeyboardKey.f5, modifier: []), // Function keys can be registered without modifiers.
                KeyboardHotkey(key: KeyboardKey.a, modifier: .commandKey),
                KeyboardHotkey(key: KeyboardKey.a, modifier: .optionKey),
                KeyboardHotkey(key: KeyboardKey.a, modifier: .controlKey)
            ]

            for hotkey in hotkeys {
                expect(HotkeyObserver(active: true).add(hotkey: hotkey, handler: {}).definitions.first?.error).to(beNil(), description: String(describing: hotkey))
            }
        }

        it("must produce definition error when adding invalid hotkey observation") {
            let hotkeys: [KeyboardHotkey] = [
                KeyboardHotkey(key: KeyboardKey.a, modifier: .capsLockKey), // Caps lock is not a valid modifier.
                KeyboardHotkey(key: KeyboardKey.a, modifier: [.capsLockKey, .controlKey]) // Or any combination.
            ]

            for hotkey in hotkeys {
                expect(HotkeyObserver(active: true).add(hotkey: hotkey, handler: {}).definitions.first?.error).toNot(beNil(), description: String(describing: hotkey))
            }
        }

        it("must produce definition error when adding the same hotkey twice") {
            let observerFoo: HotkeyObserver = HotkeyObserver(active: true)
            let observerBar: HotkeyObserver = HotkeyObserver(active: true)
            let hotkey: KeyboardHotkey = KeyboardHotkey(key: KeyboardKey.five, modifier: [.commandKey, .shiftKey])

            observerFoo.add(hotkey: hotkey, handler: {})
            observerBar.add(hotkey: hotkey, handler: {})
            expect(observerBar.definitions.first?.error).toNot(beNil())
        }
    }

    private func readmeSample() {
        let observer: HotkeyObserver = HotkeyObserver(active: true)
        let fooHotkey: KeyboardHotkey = KeyboardHotkey(key: KeyboardKey.five, modifier: [.commandKey, .shiftKey])
        let barHotkey: KeyboardHotkey = KeyboardHotkey(key: KeyboardKey.six, modifier: [.commandKey, .shiftKey])

        observer
            .add(hotkey: fooHotkey) { Swift.print("Such foo…") }
            .add(hotkey: barHotkey) { Swift.print("So bar…") }
    }
}