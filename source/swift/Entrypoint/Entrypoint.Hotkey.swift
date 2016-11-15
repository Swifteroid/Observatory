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

    private lazy var hotkeyObserver: HotkeyObserver = HotkeyObserver(active: true)
    private lazy var buttonObserver: NotificationObserver = NotificationObserver(active: true)

    // MARK: -

    override public func viewDidLoad() {
        let notifications: [String] = [HotkeyRecorderButton.Notification.HotkeyWillChange, HotkeyRecorderButton.Notification.HotkeyDidChange]

        try! buttonObserver
            .add(notifications, observable: self.buttonFoo, handler: { [unowned self] in self.handleButtonNotification($0) })
            .add(notifications, observable: self.buttonBar, handler: { [unowned self] in self.handleButtonNotification($0) })
    }

    private func handleButtonNotification(notification: NSNotification) {
        guard let hotkey: KeyboardHotkey = (notification.object as! HotkeyRecorderButton).hotkey else {
            return
        }

        if notification.name == HotkeyRecorderButton.Notification.HotkeyWillChange {
            hotkeyObserver.remove(hotkey)
        } else if notification.name == HotkeyRecorderButton.Notification.HotkeyDidChange {
            try! hotkeyObserver.add(hotkey, handler: { [unowned self] in self.handleHotkey($0) })
        }
    }

    private func handleHotkey(hotkey: KeyboardHotkey) {
        Swift.print(hotkey)
    }
}