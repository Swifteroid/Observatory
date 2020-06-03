import Carbon
import Foundation
import Nimble
import Observatory
import Quick

internal class ShortcutSpec: Spec {
    override internal func spec() {

        // Do this prior running any tests to "flush" the `NSWillBecomeMultiThreadedNotification` notification, which fails tests
        // that expect certain notifications.
        self.postHotkeyEvent(key: CGKeyCode(KeyboardKey.escape.rawValue), flag: [])

        // Cleanup registered shortcuts after each test.
        afterEach({ ShortcutCenter.default.shortcuts.forEach({ $0.isEnabled = false }) })

        it("can update registration") {
            var shortcut: Shortcut

            shortcut = Shortcut()
            expect(shortcut.isRegistered) == false

            shortcut = Shortcut(KeyboardHotkey(key: .one, modifier: [.commandKey, .shiftKey]), isEnabled: false)
            expect(shortcut.isRegistered) == false

            shortcut = Shortcut(KeyboardHotkey(key: .one, modifier: [.commandKey, .shiftKey]))
            expect(shortcut.isRegistered) == true
            shortcut.isEnabled = false
            expect(shortcut.isRegistered) == false

            shortcut = Shortcut(KeyboardHotkey(key: .one, modifier: [.commandKey, .shiftKey]))
            expect(shortcut.isRegistered) == true
            shortcut.hotkey = nil
            expect(shortcut.isRegistered) == false

            shortcut = Shortcut(KeyboardHotkey(key: .one, modifier: .shiftKey))
            expect(shortcut.isRegistered) == false

            shortcut = Shortcut(KeyboardHotkey(key: .one, modifier: .capsLockKey))
            expect(shortcut.isRegistered) == false
        }

        it("can add and remove observations") {
            let shortcut: Shortcut = Shortcut(KeyboardHotkey(key: .one, modifier: [.commandKey, .shiftKey]))
            let observation: Any?
            var callbacks: Int = 0

            observation = shortcut.observe({ _ in callbacks += 1 })
            self.postHotkeyEvent(key: CGKeyCode(KeyboardKey.one.rawValue), flag: [.maskCommand, .maskShift])
            expect(callbacks) == 1

            shortcut.unobserve(observation!)
            self.postHotkeyEvent(key: CGKeyCode(KeyboardKey.one.rawValue), flag: [.maskCommand, .maskShift])
            expect(callbacks) == 1
        }

        it("must post notifications when registered shortcut gets invoked") {
            let shortcut = Shortcut(KeyboardHotkey(key: .one, modifier: [.commandKey, .shiftKey]))
            let center: ShortcutCenter = .default

            expect(expression: { self.postHotkeyEvent(key: CGKeyCode(KeyboardKey.one.rawValue), flag: [.maskCommand, .maskShift]) })
                .to(postNotifications(equal([
                    Notification(name: ShortcutCenter.shortcutWillInvokeNotification, object: center, userInfo: [ShortcutCenter.shortcutUserInfo: shortcut]),
                    Notification(name: ShortcutCenter.shortcutDidInvokeNotification, object: center, userInfo: [ShortcutCenter.shortcutUserInfo: shortcut]),
                ])))
        }
    }
}
