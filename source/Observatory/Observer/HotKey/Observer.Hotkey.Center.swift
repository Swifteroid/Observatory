import Foundation

open class HotkeyCenter
{
    open static let `default`: HotkeyCenter = HotkeyCenter()

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

    private lazy var hotkeyObserver: HotkeyObserver = HotkeyObserver(active: true)

    private func handle(hotkey: KeyboardHotkey) {
        if let command: String = self.commands[hotkey] {
            NotificationCenter.default.post(name: HotkeyCenter.commandDidInvokeNotification, object: self, userInfo: [HotkeyCenter.commandUserInfo: command, HotkeyCenter.hotkeyUserInfo: hotkey])
        }
    }

    /// Current hotkey recorder, normally is set and unset by the assigned value itself.
    open var recorder: HotkeyRecorder? = nil {
        didSet {
            if self.recorder === oldValue { return }
            self.update()
        }
    }

    /// Hotkey command master registry is a single source of all hotkeys in the application and associated commands. Associated hotkeys
    /// are automatically observed and `CommandDidInvoke` notification gets posted when they get invoked.
    open private(set) var commands: [KeyboardHotkey: String] = [:]

    @discardableResult open func add(hotkey: KeyboardHotkey, command: String) -> Self {
        if self.commands[hotkey] == command { return self }
        if self.commands[hotkey] == nil { self.hotkeyObserver.add(hotkey: hotkey, handler: { [weak self] in self?.handle(hotkey: $0) }) }
        self.commands[hotkey] = command
        return self
    }

    @discardableResult open func remove(hotkey: KeyboardHotkey) -> Self {
        if self.commands[hotkey] == nil { return self }
        self.hotkeyObserver.remove(hotkey: hotkey)
        self.commands.removeValue(forKey: hotkey)
        return self
    }

    open func update() {
        for observer in self.observers {
            for definition in observer.definitions {
                definition.ignore(self.recorder != nil)
            }
        }
    }
}

extension HotkeyCenter
{

    /// Notification name posted when a registered hotkey invokes associated command. Includes user info with hotkey and command details.
    public static let commandDidInvokeNotification: Notification.Name = .init("\(HotkeyCenter.self)CommandDidInvokeNotification")

    /// Hotkey user info key name associated with `KeyboardHotkey` value provided with `commandDidInvokeNotification` notification.
    public static let hotkeyUserInfo: String = "hotkey"

    /// Command user info key name associated with command value provided with `commandDidInvokeNotification` notification.
    public static let commandUserInfo: String = "command"
}