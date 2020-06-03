import Foundation

/// Shortcut provides a convenient hotkey observation model. Shortcut has two control points: a `hotkey` value, which is optional
/// and can be `nil`, and `isEnabled` flag. For the shortcut to be globally registered it must be, both, enabled and have a valid
/// hotkey.
open class Shortcut {
    public init(_ hotkey: KeyboardHotkey? = nil, isEnabled: Bool? = nil) {
        self.hotkey = hotkey
        if let isEnabled = isEnabled { self.isEnabled = isEnabled }
        self.update()
    }

    /// The shortcut's hotkey. If hotkey is not provided or not valid the shortcut will not registered in the default
    /// `ShortcutCenter`.
    open var hotkey: KeyboardHotkey? {
        didSet { self.update() }
    }

    /// Specifies whether the shortcut is enabled or not. When not enabled shortcut will not be registered in the default
    /// `ShortcutCenter`.
    open var isEnabled: Bool = true {
        didSet { self.update() }
    }

    /// Checks whether the shortcut is registered in the default `ShortcutCenter` or not.
    open var isRegistered: Bool {
        ShortcutCenter.default.shortcuts.contains(self)
    }

    /// Checks whether the shortcut is valid. The default implementation checks if the modifier contains command, control or option keys, 
    /// thus, disallowing "plain" combinations with shift and caps-lock modifiers.
    open var isValid: Bool {
        guard let modifier = self.hotkey?.modifier else { return false }
        return modifier.contains(.commandKey) || modifier.contains(.controlKey) || modifier.contains(.optionKey)
    }

    /// Updates registration in the default `ShortcutCenter`.
    private func update() {
        ShortcutCenter.default.update(self)
    }


    // MARK: Observing


    /// Registered shortcut observers.
    fileprivate var observations: [Observation] = []

    /// Creates a new observations. You don't need to retain the value to keep it alive, but it's needed to remove
    /// the observation.
    @discardableResult open func observe(_ action: @escaping Action) -> Any {
        let observation = Observation(action)
        self.observations.append(observation)
        return observation
    }

    /// Removes the observation.
    open func unobserve(_ observation: Any) {
        guard let observation = observation as? Observation else { return }
        guard let index = self.observations.firstIndex(where: { $0 === observation }) else { return }
        self.observations.remove(at: index)
    }

    /// Invokes the shortcut's registered observations.
    internal func invoke() {
        self.observations.forEach({ $0.action(self) })
    }
}

extension Shortcut: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Shortcut, rhs: Shortcut) -> Bool { lhs === rhs }
}

extension Shortcut: CustomStringConvertible {
    public var description: String { "<\(Self.self): 0x\(String(Int(bitPattern: Unmanaged.passUnretained(self).toOpaque()), radix: 16)), hotkey:\(self.hotkey?.description ?? "nil"), observations: \(self.observations.count)>" }
}

extension Shortcut {
    /// Shortcut observation action gets called when the shortcut is triggered.
    public typealias Action = (Shortcut) -> Void

    fileprivate final class Observation {
        fileprivate init(_ action: @escaping Action) { self.action = action }
        fileprivate let action: Action
    }
}
