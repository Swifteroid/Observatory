import Carbon
import Foundation
import Nimble
import Observatory
import Quick

internal class HotkeyCenterSpec: Spec
{
    override internal func spec() {
        it("must post command invocation notification when registered hotkey gets pressed") {
            let center: HotkeyCenter = .default
            let fooHotkey = KeyboardHotkey(key: .one, modifier: [.commandKey, .shiftKey])
            let barHotkey = KeyboardHotkey(key: .two, modifier: [.commandKey, .shiftKey])

            center.add(hotkey: fooHotkey, command: "foo")
            center.add(hotkey: barHotkey, command: "bar")

            expect(expression: { self.postHotkeyEvent(key: CGKeyCode(KeyboardKey.one.rawValue), flag: [.maskCommand, .maskShift]) })
                .to(postNotifications(equal([Notification(name: HotkeyCenter.commandDidInvokeNotification, object: center, userInfo: [
                    HotkeyCenter.commandUserInfo: "foo",
                    HotkeyCenter.hotkeyUserInfo: fooHotkey
                ])])))

            expect(expression: { self.postHotkeyEvent(key: CGKeyCode(KeyboardKey.two.rawValue), flag: [.maskCommand, .maskShift]) })
                .to(postNotifications(equal([Notification(name: HotkeyCenter.commandDidInvokeNotification, object: center, userInfo: [
                    HotkeyCenter.commandUserInfo: "bar",
                    HotkeyCenter.hotkeyUserInfo: barHotkey
                ])])))
        }
    }
}