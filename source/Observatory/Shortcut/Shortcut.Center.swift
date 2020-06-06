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
            self.observer.isActive = !isIgnored
        }
    }

    /// Independently stores registered shortcut hotkeys.
    private var registrations: [Registration] = []

    /// All shortcuts registered in the center.
    open var shortcuts: [Shortcut] { self.registrations.lazy.map({ $0.shortcut }) }

    /// Registers the shortcut-hotkey pair.
    private func add(_ shortcut: Shortcut, _ hotkey: KeyboardHotkey) {
        guard !self.registrations.contains(where: { $0.shortcut == shortcut || $0.hotkey == hotkey }) else {
            return self.notify(Self.cannotRegisterShortcutNotification, shortcut)
        }

        self.registrations.append(Registration(shortcut, hotkey))
        self.observer.add(hotkey: hotkey, handler: { [weak self] in self?.invoke($0) })
        self.notify(Self.didRegisterShortcutNotification, shortcut)
    }

    /// Unregisters the shortcut.
    private func remove(_ shortcut: Shortcut) {
        guard let index = self.registrations.firstIndex(where: { $0.shortcut == shortcut }) else {
            return
        }

        let registration = self.registrations.remove(at: index)
        self.observer.remove(hotkey: registration.hotkey)
        self.notify(Self.didUnregisterShortcutNotification, shortcut)
    }

    /// Updates the shortcut registration.
    internal func update(_ shortcut: Shortcut) {
        let oldHotkey = self.registrations.first(where: { $0.shortcut == shortcut })?.hotkey
        let newHotkey = shortcut.hotkey

        // Need to register if the new hotkey is okay. 
        let needsRegister = newHotkey != nil && shortcut.isValid && shortcut.isEnabled
        // Need to unregister if hotkey is already registered but doesn't need to be or if hotkeys are different. 
        let needsUnregister = oldHotkey != nil && !needsRegister || newHotkey != oldHotkey

        if needsUnregister { self.remove(shortcut) }
        if needsRegister, let hotkey = newHotkey { self.add(shortcut, hotkey) }
    }

    /// Invokes a registered shortcut with the hotkey.
    private func invoke(_ hotkey: KeyboardHotkey) {
        guard let shortcut = self.shortcuts.first(where: { $0.hotkey == hotkey }) else { return }
        self.notify(Self.willInvokeShortcutNotification, shortcut)
        shortcut.invoke()
        self.notify(Self.didInvokeShortcutNotification, shortcut)
    }
}

extension ShortcutCenter {
    fileprivate struct Registration {
        init(_ shortcut: Shortcut, _ hotkey: KeyboardHotkey) {
            self.shortcut = shortcut
            self.hotkey = hotkey
        }
        fileprivate let shortcut: Shortcut
        fileprivate let hotkey: KeyboardHotkey
    }
}

extension ShortcutCenter {
    /// Convenience notification posting.
    fileprivate func notify(_ name: Notification.Name, _ shortcut: Shortcut) {
        NotificationCenter.default.post(name: name, object: self, userInfo: [Self.shortcutUserInfo: shortcut])
    }
}

extension ShortcutCenter {
    /// Posted after failing to register a shortcut. Includes `userInfo` with the `shortcut` key.
    public static let cannotRegisterShortcutNotification = Notification.Name("\(ShortcutCenter.self)CannotNotRegisterShortcutNotification")

    /// Posted after successfully registering a shortcut. Includes `userInfo` with the `shortcut` key.
    public static let didRegisterShortcutNotification = Notification.Name("\(ShortcutCenter.self)DidRegisterShortcutNotification")

    /// Posted after successfully unregistering a shortcut. Includes `userInfo` with the `shortcut` key.
    public static let didUnregisterShortcutNotification = Notification.Name("\(ShortcutCenter.self)DidUnregisterShortcutNotification")

    /// Posted prior invoking a registered shortcut. Includes `userInfo` with the `shortcut` key.
    public static let willInvokeShortcutNotification = Notification.Name("\(ShortcutCenter.self)WillInvokeShortcutNotification")

    /// Posted after invoking a registered shortcut. Includes `userInfo` with the `shortcut` key.
    public static let didInvokeShortcutNotification = Notification.Name("\(ShortcutCenter.self)DidInvokeShortcutNotification")

    /// Notification `userInfo` key containing the `Shortcut` object.
    public static let shortcutUserInfo: String = "shortcut"
}
