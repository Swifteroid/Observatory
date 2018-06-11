import Foundation

/// Hotkey center provides a simple interface for registering predefined hotkey commands. It sub-manages active hotkey 
/// recorder and all hotkey observers. There's an important detail to keep in mind, that all observers get disabled 
/// whilst `recorder` value is not `nil`, see related property for details.
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

    internal func register(observer: HotkeyObserver) {
        self.observers.append(observer)
    }

    internal func unregister(observer: HotkeyObserver) {
        self.observers = self.observers.filter({ $0 !== observer })
    }

    private lazy var hotkeyObserver: HotkeyObserver = HotkeyObserver(active: true)

    private func handle(hotkey: KeyboardHotkey) {
        guard  let command: HotkeyCommand = self.commands[hotkey] else { return }
        NotificationCenter.default.post(name: HotkeyCenter.commandDidInvokeNotification, object: self, userInfo: [HotkeyCenter.commandUserInfo: command, HotkeyCenter.hotkeyUserInfo: hotkey])
    }

    /// Current hotkey recorder, normally is set and unset by the assigned value itself. Whilst it's set all registered
    /// observers get disabled, to avoid triggering commands during recording.
    open var recorder: HotkeyRecorder? = nil {
        didSet {
            if self.recorder === oldValue { return }
            self.update()
        }
    }

    /// Hotkey command master registry is a single source of all hotkeys in the application and associated commands. Associated hotkeys
    /// are automatically observed and `commandDidInvoke` notification gets posted when they get invoked.
    open private(set) var commands: [KeyboardHotkey: HotkeyCommand] = [:]

    /// Registers hotkey with the command.
    @discardableResult open func add(hotkey: KeyboardHotkey, command: HotkeyCommand) -> Self {
        if self.commands[hotkey] == command { return self }
        if self.commands[hotkey] == nil { self.hotkeyObserver.add(hotkey: hotkey, handler: { [weak self] in self?.handle(hotkey: $0) }) }
        self.commands[hotkey] = command
        return self
    }

    /// Unregisters hotkey with the command.
    @discardableResult open func remove(hotkey: KeyboardHotkey) -> Self {
        if self.commands[hotkey] == nil { return self }
        self.hotkeyObserver.remove(hotkey: hotkey)
        self.commands.removeValue(forKey: hotkey)
        return self
    }

    /// Disables registered hotkey observers if there's an active hotkey recorder and enables them if there's not.
    private func update() {
        let isIgnored: Bool = self.recorder != nil
        for observer in self.observers {
            for definition in observer.definitions {
                definition.ignore(isIgnored)
            }
        }
    }
}

extension HotkeyCenter
{

    /// Notification name posted when a registered hotkey invokes associated command. Includes user info with hotkey and command details.
    public static let commandDidInvokeNotification: Notification.Name = .init("\(HotkeyCenter.self)CommandDidInvokeNotification")

    /// Hotkey user info key name associated with `KeyboardHotkey` value provided with `commandDidInvoke` notification.
    public static let hotkeyUserInfo: String = "hotkey"

    /// Command user info key name associated with command value provided with `commandDidInvoke` notification.
    public static let commandUserInfo: String = "command"
}

public struct HotkeyCommand: RawRepresentable, Hashable
{
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(_ rawValue: String) { self.rawValue = rawValue }
    public let rawValue: String
}

extension HotkeyCommand: CustomStringConvertible
{
    public var description: String { return self.rawValue }
}