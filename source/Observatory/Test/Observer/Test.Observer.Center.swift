import Carbon
import Foundation
import Nimble
import Observatory
import Quick

internal class HotkeyCenterSpec: Spec {
    override internal func spec() {
        it("must post command invocation notification when registered hotkey gets pressed") {
            let center: HotkeyCenter = .default

            center.add(hotkey: .foo, command: .foo)
            center.add(hotkey: .bar, command: .bar)

            expect(expression: { self.postHotkeyEvent(key: CGKeyCode(KeyboardKey.one.rawValue), flag: [.maskCommand, .maskShift]) })
                .to(postNotifications(equal([Notification(name: HotkeyCenter.commandDidInvokeNotification, object: center, userInfo: [
                    HotkeyCenter.commandUserInfo: HotkeyCommand.foo,
                    HotkeyCenter.hotkeyUserInfo: KeyboardHotkey.foo,
                ]), ])))

            expect(expression: { self.postHotkeyEvent(key: CGKeyCode(KeyboardKey.two.rawValue), flag: [.maskCommand, .maskShift]) })
                .to(postNotifications(equal([Notification(name: HotkeyCenter.commandDidInvokeNotification, object: center, userInfo: [
                    HotkeyCenter.commandUserInfo: HotkeyCommand.bar,
                    HotkeyCenter.hotkeyUserInfo: KeyboardHotkey.bar,
                ]), ])))
        }
    }
}

extension KeyboardHotkey {
    fileprivate static let foo: KeyboardHotkey = .init(key: .one, modifier: [.commandKey, .shiftKey])
    fileprivate static let bar: KeyboardHotkey = .init(key: .two, modifier: [.commandKey, .shiftKey])
}

extension HotkeyCommand {
    fileprivate static let foo: HotkeyCommand = .init("foo")
    fileprivate static let bar: HotkeyCommand = .init("bar")
}
