import Foundation

open class HotkeyCenter
{
    open static let instance: HotkeyCenter = HotkeyCenter()

    // MARK: observers

    private var weakObservers: [Weak] = [] {
        didSet { self.update() }
    }

    private var observers: [HotkeyObserver] {
        get { return weakObservers.reduce([], { $1.value == nil ? $0 : $0 + [$1.value as! HotkeyObserver] }) }
        set { self.weakObservers = newValue.map({ Weak(value: $0) }) }
    }

    @discardableResult open func register(observer: HotkeyObserver) -> Self {
        self.observers.append(observer)
        return self
    }

    @discardableResult open func unregister(observer: HotkeyObserver) -> Self {
        self.observers = self.observers.filter({ $0 !== observer })
        return self
    }

    // MARK: -

    private lazy var hotkeyObserver: HotkeyObserver = HotkeyObserver(active: true)

    private func handle(hotkey: KeyboardHotkey) {
        if let command: String = self.commands[hotkey] {
            NotificationCenter.default.post(name: Notification.CommandDidInvoke, object: self, userInfo: [NotificationUserInfo.Command: command, NotificationUserInfo.Hotkey: Int(hotkey.value)])
        }
    }

    // MARK: -

    /*
    Current hotkey recorder, normally is set and unset by the assigned value itself.
    */
    open var recorder: HotkeyRecorderProtocol? = nil {
        didSet {
            if self.recorder === oldValue { return }
            self.update()
        }
    }

    /*
    Hotkey command master registry is a single source of all hotkeys in the application and associated commands. Associated hotkeys
    are automatically observed and `CommandDidInvoke` notification gets posted when they get invoked.
    */
    open var commands: [KeyboardHotkey: String] = [:] {
        didSet {
            let newValue: [KeyboardHotkey: String] = self.commands
            guard newValue != oldValue else { return }

            // To avoid removing / adding all hotkeys observers we calculate differences
            // and operate only on them…

            let newValueSet: Set<KeyboardHotkey> = Set(newValue.keys)
            let oldValueSet: Set<KeyboardHotkey> = Set(oldValue.keys)

            for hotkey in Array(oldValueSet.subtracting(newValueSet)) {
                self.hotkeyObserver.remove(hotkey: hotkey)
            }

            for hotkey in Array(newValueSet.subtracting(oldValueSet)) {
                try! self.hotkeyObserver.add(hotkey: hotkey, handler: { [unowned self] in self.handle(hotkey: $0) })
            }
        }
    }

    // MARK: -

    open func update() {
        for observer in self.observers {
            for definition in observer.definitions {
                definition.ignored = self.recorder != nil
            }
        }
    }
}

extension HotkeyCenter
{
    public struct Notification
    {
        public static let CommandDidInvoke: Foundation.Notification.Name = Foundation.Notification.Name("HotkeyCenterCommandDidInvokeNotification")
    }

    public struct NotificationUserInfo
    {
        public static let Hotkey: String = "hotkey"
        public static let Command: String = "command"
    }
}