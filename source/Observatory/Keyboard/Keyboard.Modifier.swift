import AppKit.NSEvent
import Carbon

/// Check source for comments, some keys are not available on Mac OS X.
public struct KeyboardModifier: RawRepresentable, OptionSet {
    public init(rawValue: Int) { self.rawValue = rawValue }
    public init(_ rawValue: Int) { self.init(rawValue: rawValue) }
    public init(_ event: NSEvent) { self.init(event.modifierFlags) }

    public init(_ flags: NSEvent.ModifierFlags) {
        var rawValue: Int = 0

        // ✊ Leaving this as a reminder for future generations. Apparently, if you used to deal with CoreGraphics you'd know
        // what the fuck modifier flags are made of, otherwise, you are doomed. And made they are of CoreGraphics event
        // source flags state, or `CGEventSource.flagsState(.hidSystemState)` to be precise. So, an empty flag will have
        // raw value not of `0` but of `UInt(CGEventSource.flagsState(.hidSystemState).rawValue)`… For that reason, it's a real
        // pain in the ass to compare self-made modifier flags with ones coming from an `NSEvent`.

        // ✊ Also, there's a funny Caps Lock behavior – it's not included in a key down event when `.command` flag is also
        // present. This might be done on purpose, but probably not what you're expecting. However, the Caps Lock flag remains
        // available inside `NSEvent.modifierFlags`… 🤯 So, if you need Caps Lock info – initialize your modifier from that
        // and not the actual `NSEvent` instance… or do a union… or handle it else how.

        if flags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue != 0 {
            if flags.contains(.capsLock) { rawValue |= Carbon.alphaLock }
            if flags.contains(.command) { rawValue |= Carbon.cmdKey }
            if flags.contains(.control) { rawValue |= Carbon.controlKey }
            if flags.contains(.option) { rawValue |= Carbon.optionKey }
            if flags.contains(.shift) { rawValue |= Carbon.shiftKey }
        }

        self = KeyboardModifier(rawValue)
    }

    public let rawValue: Int

    public static let none: KeyboardModifier = .init(0)
    public static let capsLockKey: KeyboardModifier = .init(Carbon.alphaLock)
    public static let commandKey: KeyboardModifier = .init(Carbon.cmdKey)
    public static let controlKey: KeyboardModifier = .init(Carbon.controlKey)
    public static let optionKey: KeyboardModifier = .init(Carbon.optionKey)
    public static let shiftKey: KeyboardModifier = .init(Carbon.shiftKey)

    /// The name of the modifier.
    public var name: String? {
        let name = self.keys.compactMap({ $0.name }).joined(separator: "")
        return name == "" ? nil : name
    }

    /// Returns keys associated with the modifier. Note, different keys can result in the same modifier, if you need
    /// the precise keys and in precise order they were pressed, this needs to be tracked done with event tracking.
    public var keys: [KeyboardKey] {
        // Keep the order: https://developer.apple.com/design/human-interface-guidelines/inputs/keyboards/#custom-keyboard-shortcuts
        //  > List modifier keys in the correct order. If you use more than one modifier key in a custom
        //  > shortcut, always list them in this order: Control, Option, Shift, Command.
        var keys = [KeyboardKey]()
        if self.contains(.controlKey) { keys.append(KeyboardKey.control) }
        if self.contains(.optionKey) { keys.append(KeyboardKey.option) }
        if self.contains(.capsLockKey) { keys.append(KeyboardKey.capsLock) }
        if self.contains(.shiftKey) { keys.append(KeyboardKey.shift) }
        if self.contains(.commandKey) { keys.append(KeyboardKey.command) }
        return keys
    }
}

extension KeyboardModifier: Equatable, Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(self.rawValue) }
}

extension KeyboardModifier: CustomStringConvertible {
    public var description: String { self.name ?? "" }
}
