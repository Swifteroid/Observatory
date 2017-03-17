import AppKit
import Observatory

@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate
{
}

open class ViewController: NSViewController
{
    @IBOutlet private weak var buttonFoo: HotkeyRecorderButton!
    @IBOutlet private weak var buttonBar: HotkeyRecorderButton!

    // MARK: intercom

    private lazy var hotkeyCommandObserver: NotificationObserver = NotificationObserver(active: true)

    // MARK: -

    override open func viewDidLoad() {
        try! hotkeyCommandObserver.add(name: HotkeyCenter.Notification.CommandDidInvoke, observable: HotkeyCenter.default, handler: { [unowned self] in self.handleHotkeyCommandNotification(notification: $0) })
    }

    private func handleHotkeyCommandNotification(notification: Notification) {
        let info: [String: AnyObject] = notification.userInfo as! [String: AnyObject]
        let command: String = info[HotkeyCenter.NotificationUserInfo.Command] as! String
        let hotkey: KeyboardHotkey = KeyboardHotkey(value: UInt64(info[HotkeyCenter.NotificationUserInfo.Hotkey] as! Int))
        Swift.print(command, hotkey)
    }
}