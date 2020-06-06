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

        it("must post notifications when hotkey gets changed") {
            // Keep shortcut disabled to avoid `ShortcutCenter` registration notifications.
            let shortcut = Shortcut(isEnabled: false)
            let hotkey = KeyboardHotkey(key: .one, modifier: [.commandKey, .shiftKey])

            expect(expression: { shortcut.hotkey = hotkey })
                .to(postNotifications(equal([
                    Notification(name: Shortcut.hotkeyWillChangeNotification, object: shortcut, userInfo: [Shortcut.hotkeyUserInfo: hotkey]),
                    Notification(name: Shortcut.hotkeyDidChangeNotification, object: shortcut, userInfo: [Shortcut.hotkeyUserInfo: hotkey]),
                ])))

            expect(expression: { shortcut.hotkey = nil })
                .to(postNotifications(equal([
                    Notification(name: Shortcut.hotkeyWillChangeNotification, object: shortcut, userInfo: [Shortcut.hotkeyUserInfo: nil as KeyboardHotkey? as Any]),
                    Notification(name: Shortcut.hotkeyDidChangeNotification, object: shortcut, userInfo: [Shortcut.hotkeyUserInfo: nil as KeyboardHotkey? as Any]),
                ])))
        }

        it("must post notifications when registered shortcut gets invoked") {
            let hotkey = KeyboardHotkey(key: .one, modifier: [.commandKey, .shiftKey])
            let shortcut = Shortcut(hotkey)
            let center: ShortcutCenter = .default

            expect(expression: { self.postHotkeyEvent(key: CGKeyCode(KeyboardKey.one.rawValue), flag: [.maskCommand, .maskShift]) })
                .to(postNotifications(equal([
                    Notification(name: ShortcutCenter.willInvokeShortcutNotification, object: center, userInfo: [ShortcutCenter.shortcutUserInfo: shortcut, ShortcutCenter.hotkeyUserInfo: hotkey]),
                    Notification(name: ShortcutCenter.didInvokeShortcutNotification, object: center, userInfo: [ShortcutCenter.shortcutUserInfo: shortcut, ShortcutCenter.hotkeyUserInfo: hotkey]),
                ])))
        }
    }
}
