import AppKit
import Observatory

@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate
{
}

public class ViewController: NSViewController
{
    @IBOutlet private weak var buttonFoo: HotkeyRecorderButton!
    @IBOutlet private weak var buttonBar: HotkeyRecorderButton!

    // MARK: intercom

    private lazy var hotkeyCommandObserver: NotificationObserver = NotificationObserver(active: true)

    // MARK: -

    override public func viewDidLoad() {
        try! hotkeyCommandObserver.add(HotkeyCenter.Notification.CommandDidInvoke, observable: HotkeyCenter.instance, handler: { [unowned self] in self.handleHotkeyCommandNotification($0) })
    }

    private func handleHotkeyCommandNotification(notification: NSNotification) {
        let info: [String: AnyObject] = notification.userInfo as! [String: AnyObject]
        let command: String = info[HotkeyCenter.NotificationUserInfo.Command] as! String
        let hotkey: KeyboardHotkey = KeyboardHotkey(value: UInt64(info[HotkeyCenter.NotificationUserInfo.Hotkey] as! Int))
        Swift.print(command, hotkey)
    }
}