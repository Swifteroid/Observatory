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

        if flags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue != 0 {
            if flags.contains(.capsLock) { rawValue |= Carbon.alphaLock }
            if flags.contains(.option) { rawValue |= Carbon.optionKey }
            if flags.contains(.command) { rawValue |= Carbon.cmdKey }
            if flags.contains(.control) { rawValue |= Carbon.controlKey }
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

    public var name: String? {
        var string: String = ""
        if self.contains(.controlKey) { string += "⌃" }
        if self.contains(.optionKey) { string += "⌥" }
        if self.contains(.capsLockKey) { string += "⇪" }
        if self.contains(.shiftKey) { string += "⇧" }
        if self.contains(.commandKey) { string += "⌘" }
        return string == "" ? nil : string
    }
}

extension KeyboardModifier: Equatable, Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(self.rawValue) }
}

extension KeyboardModifier: CustomStringConvertible {
    public var description: String { self.name ?? "" }
}
