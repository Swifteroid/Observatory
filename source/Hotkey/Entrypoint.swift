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
        (self.buttonFoo.hotkey, self.buttonFoo.command) = (.foo, .foo)
        (self.buttonBar.hotkey, self.buttonBar.command) = (.bar, .bar)
        (self.buttonBaz.hotkey, self.buttonBaz.command) = (.baz, .baz)
        (self.buttonQux.hotkey, self.buttonQux.command) = (.qux, .qux)

        hotkeyCommandObserver.add(name: HotkeyCenter.commandDidInvokeNotification, observee: HotkeyCenter.default, handler: { [weak self] in self?.handleHotkeyCommandNotification(notification: $0) })
    }

    private func handleHotkeyCommandNotification(notification: Notification) {
        let info: [String: Any] = notification.userInfo as! [String: Any]
        let command: HotkeyCommand = info[HotkeyCenter.commandUserInfo] as! HotkeyCommand
        let hotkey: KeyboardHotkey = info[HotkeyCenter.hotkeyUserInfo] as! KeyboardHotkey

        Swift.print(command, hotkey)
    }
}

extension KeyboardHotkey
{
    fileprivate static let foo: KeyboardHotkey = .init(key: .one, modifier: [.commandKey, .shiftKey])
    fileprivate static let bar: KeyboardHotkey = .init(key: .two, modifier: [.commandKey, .shiftKey])
    fileprivate static let baz: KeyboardHotkey = .init(key: .three, modifier: [.commandKey, .shiftKey])
    fileprivate static let qux: KeyboardHotkey = .init(key: .four, modifier: [.commandKey, .shiftKey])
}

extension HotkeyCommand
{
    fileprivate static let foo: HotkeyCommand = .init("foo")
    fileprivate static let bar: HotkeyCommand = .init("bar")
    fileprivate static let baz: HotkeyCommand = .init("baz")
    fileprivate static let qux: HotkeyCommand = .init("qux")
}