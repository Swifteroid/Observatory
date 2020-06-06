import AppKit
import Observatory

@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate {
}

open class ViewController: NSViewController {
    @IBOutlet private weak var buttonFoo: ShortcutRecorderButton!
    @IBOutlet private weak var buttonBar: ShortcutRecorderButton!
    @IBOutlet private weak var buttonBaz: ShortcutRecorderButton!
    @IBOutlet private weak var buttonQux: ShortcutRecorderButton!
    @IBOutlet private weak var buttonFex: ShortcutRecorderButton!

    /// Shortcut center observer.
    private lazy var observer: NotificationObserver = NotificationObserver(active: true)

    override open func viewDidLoad() {
        self.buttonFoo.shortcut = .foo
        self.buttonBar.shortcut = .bar
        self.buttonBaz.shortcut = .baz
        self.buttonQux.shortcut = .qux
        self.buttonFex.shortcut = Shortcut()

        observer.add(name: ShortcutCenter.willInvokeShortcutNotification, observee: ShortcutCenter.default, handler: { [weak self] in self?.handleShortcutCenterNotification(notification: $0) })
        observer.add(name: ShortcutCenter.didInvokeShortcutNotification, observee: ShortcutCenter.default, handler: { [weak self] in self?.handleShortcutCenterNotification(notification: $0) })
    }

    override open func viewDidAppear() {
        /// Reset first responder, do it asynchronously, because the window will modify it once presented.
        DispatchQueue.main.async(execute: { self.view.window?.makeFirstResponder(nil) })
    }

    private func handleShortcutCenterNotification(notification: Notification) {
        let info: [String: Any] = notification.userInfo as! [String: Any]
        let shortcut: Shortcut = info[ShortcutCenter.shortcutUserInfo] as! Shortcut
        Swift.print("\(notification.name.rawValue): \(shortcut)")
    }
}

extension Shortcut {
    fileprivate static let foo = Shortcut(KeyboardHotkey(key: .one, modifier: [.commandKey, .shiftKey]))
    fileprivate static let bar = Shortcut(KeyboardHotkey(key: .two, modifier: [.commandKey, .shiftKey]))
    fileprivate static let baz = Shortcut(KeyboardHotkey(key: .three, modifier: [.commandKey, .shiftKey]))
    fileprivate static let qux = Shortcut(KeyboardHotkey(key: .four, modifier: [.commandKey, .shiftKey]))
}
