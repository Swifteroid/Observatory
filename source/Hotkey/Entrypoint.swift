import AppKit
import Observatory

@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate
{
}

open class ViewController: NSViewController
{
    @IBOutlet private weak var buttonFoo: HotkeyRecorderButton!
    @IBOutlet private weak var buttonBar: HotkeyRecorderButton!
    @IBOutlet private weak var buttonBaz: HotkeyRecorderButton!
    @IBOutlet private weak var buttonQux: HotkeyRecorderButton!

    private lazy var hotkeyCommandObserver: NotificationObserver = NotificationObserver(active: true)

    override open func viewDidLoad() {
        self.buttonFoo.hotkey = KeyboardHotkey(key: .one, modifier: [.commandKey, .shiftKey])
        self.buttonBar.hotkey = KeyboardHotkey(key: .two, modifier: [.commandKey, .shiftKey])
        self.buttonBaz.hotkey = KeyboardHotkey(key: .three, modifier: [.commandKey, .shiftKey])
        self.buttonQux.hotkey = KeyboardHotkey(key: .four, modifier: [.commandKey, .shiftKey])

        hotkeyCommandObserver.add(name: HotkeyCenter.Notification.CommandDidInvoke, observee: HotkeyCenter.default, handler: { [weak self] in self?.handleHotkeyCommandNotification(notification: $0) })
    }

    private func handleHotkeyCommandNotification(notification: Notification) {
        let info: [String: AnyObject] = notification.userInfo as! [String: AnyObject]
        let command: String = info[HotkeyCenter.NotificationUserInfo.Command] as! String
        let hotkey: KeyboardHotkey = KeyboardHotkey(info[HotkeyCenter.NotificationUserInfo.Hotkey] as! Int)
        Swift.print(command, hotkey)
    }
}