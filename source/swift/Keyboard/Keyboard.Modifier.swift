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
            if flags.contains(.capsLock) { rawValue |= UInt32(Carbon.alphaLock) }
            if flags.contains(.option) { rawValue |= UInt32(Carbon.optionKey) }
            if flags.contains(.command) { rawValue |= UInt32(Carbon.cmdKey) }
            if flags.contains(.control) { rawValue |= UInt32(Carbon.controlKey) }
            if flags.contains(.shift) { rawValue |= UInt32(Carbon.shiftKey) }
        }

        self = KeyboardModifier(rawValue: rawValue)
    }

    // MARK: -

    public static let none = KeyboardModifier(rawValue: 0)
    public static let capsLock = KeyboardModifier(rawValue: UInt32(Carbon.alphaLock))
    public static let commandKey = KeyboardModifier(rawValue: UInt32(Carbon.cmdKey))
    public static let controlKey = KeyboardModifier(rawValue: UInt32(Carbon.controlKey))
    public static let optionKey = KeyboardModifier(rawValue: UInt32(Carbon.optionKey))
    public static let shiftKey = KeyboardModifier(rawValue: UInt32(Carbon.shiftKey))

    // MARK: -

    public var name: String? {
        var string: String = ""

        if self.contains(.capsLock) { string += "⇪" }
        if self.contains(.commandKey) { string += "⌘" }
        if self.contains(.controlKey) { string += "⌃" }
        if self.contains(.optionKey) { string += "⌥" }
        if self.contains(.shiftKey) { string += "⇧" }

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