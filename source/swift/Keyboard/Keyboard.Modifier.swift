import AppKit.NSEvent
import Carbon

/*
Check source for comments, some keys are not available on Mac OS X.
*/
public struct KeyboardModifier: OptionSet
{
    public typealias RawValue = UInt32
    public let rawValue: UInt32

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public init(flags: NSEventModifierFlags) {
        var rawValue: UInt32 = 0

        if flags.rawValue & NSEventModifierFlags.deviceIndependentFlagsMask.rawValue != 0 {
            if flags.contains(NSEventModifierFlags.capsLock) { rawValue |= UInt32(Carbon.alphaLock) }
            if flags.contains(NSEventModifierFlags.option) { rawValue |= UInt32(Carbon.optionKey) }
            if flags.contains(NSEventModifierFlags.command) { rawValue |= UInt32(Carbon.cmdKey) }
            if flags.contains(NSEventModifierFlags.control) { rawValue |= UInt32(Carbon.controlKey) }
            if flags.contains(NSEventModifierFlags.shift) { rawValue |= UInt32(Carbon.shiftKey) }
        }

        self = KeyboardModifier(rawValue: rawValue)
    }

    // MARK: -

    public static let None = KeyboardModifier(rawValue: 0)
    public static let CapsLock = KeyboardModifier(rawValue: UInt32(Carbon.alphaLock))
    public static let CommandKey = KeyboardModifier(rawValue: UInt32(Carbon.cmdKey))
    public static let ControlKey = KeyboardModifier(rawValue: UInt32(Carbon.controlKey))
    public static let OptionKey = KeyboardModifier(rawValue: UInt32(Carbon.optionKey))
    public static let ShiftKey = KeyboardModifier(rawValue: UInt32(Carbon.shiftKey))

    // MARK: -

    public var name: String? {
        var string: String = ""

        if self.contains(KeyboardModifier.CapsLock) { string += "⇪" }
        if self.contains(KeyboardModifier.CommandKey) { string += "⌘" }
        if self.contains(KeyboardModifier.ControlKey) { string += "⌃" }
        if self.contains(KeyboardModifier.OptionKey) { string += "⌥" }
        if self.contains(KeyboardModifier.ShiftKey) { string += "⇧" }

        return string == "" ? nil : string
    }

    public static func name(for modifier: UInt32) -> String? {
        return KeyboardModifier(rawValue: modifier).name
    }
}

// MARK: -

extension KeyboardModifier: CustomStringConvertible
{
    public var description: String {
        return self.name ?? ""
    }
}