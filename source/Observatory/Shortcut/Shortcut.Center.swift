import Foundation

/// The shortcut center provides an interface for registering predefined hotkey commands. It sub-manages active hotkey
/// recorder and all hotkey observers. There's an important detail to keep in mind, that all observers get disabled
/// whilst `recorder` value is not `nil`, see related property for details.
open class ShortcutCenter {
    public static var `default`: ShortcutCenter = ShortcutCenter()

    /// The hotkey observer.
    private let observer: HotkeyObserver = HotkeyObserver(active: true)

    /// Current hotkey recorder, normally is set and unset by the assigned value itself. Whilst it's set all registered
    /// observers get disabled, to avoid triggering commands during recording.
    open var recorder: ShortcutRecorder? = nil {
        didSet {
            if self.recorder === oldValue { return }
            /// Disables registered hotkey observers if there's an active hotkey recorder and enables them if there's not.
            let isIgnored: Bool = self.recorder != nil
            self.observer.definitions.forEach({ $0.ignore(isIgnored) })
        }
    }

    /// Independently stores registered shortcut hotkeys.
    private var hotkeys: [Shortcut: KeyboardHotkey] = [:]

    /// All shortcuts registered in the center.
    open private(set) var shortcuts: [Shortcut] = []

    /// Adds (registers) the shortcut if it has a valid hotkey.
    internal func add(_ shortcut: Shortcut) {
        guard let hotkey = shortcut.hotkey, !self.shortcuts.contains(shortcut), !self.hotkeys.values.contains(hotkey) else { return }
        self.shortcuts.append(shortcut)
        self.hotkeys[shortcut] = hotkey
        self.observer.add(hotkey: hotkey, handler: { [weak self] in self?.invoke($0) })
    }

    /// Removes (unregisters) the shortcut.
    internal func remove(_ shortcut: Shortcut) {
        guard let index = self.shortcuts.firstIndex(of: shortcut) else { return }
        self.shortcuts.remove(at: index)
        guard let hotkey = self.hotkeys.removeValue(forKey: shortcut) else { return }
        self.observer.remove(hotkey: hotkey)
    }

    /// Updates the shortcut registration.
    internal func update(_ shortcut: Shortcut) {
        let oldHotkey = self.hotkeys[shortcut]
        let newHotkey = shortcut.hotkey
        let isRegistrable = shortcut.isValid && shortcut.isEnabled
        if !isRegistrable || newHotkey != oldHotkey { self.remove(shortcut) }
        if isRegistrable { self.add(shortcut) }
    }

    /// Invokes a registered shortcut with the hotkey.
    private func invoke(_ hotkey: KeyboardHotkey) {
        guard let shortcut = self.shortcuts.first(where: { $0.hotkey == hotkey }) else { return }
        NotificationCenter.default.post(name: Self.shortcutWillInvokeNotification, object: self, userInfo: [Self.shortcutUserInfo: shortcut])
        shortcut.invoke()
        NotificationCenter.default.post(name: Self.shortcutDidInvokeNotification, object: self, userInfo: [Self.shortcutUserInfo: shortcut])
    }
}

extension ShortcutCenter {
    /// Posted prior invoking a registered shortcut. Includes `userInfo` with the `shortcut` key.
    public static let shortcutWillInvokeNotification = Notification.Name("\(ShortcutCenter.self)ShortcutWillInvokeNotification")

    /// Posted after invoking a registered shortcut. Includes `userInfo` with the `shortcut` key.
    public static let shortcutDidInvokeNotification = Notification.Name("\(ShortcutCenter.self)ShortcutDidInvokeNotification")

    /// Notification `userInfo` key containing the `Shortcut` object.
    public static let shortcutUserInfo: String = "shortcut"
}
