import Foundation
import AppKit
import Carbon

/*
Check source for comments, some keys are not available on Mac OS X.
*/
public struct KeyboardModifier: OptionSetType
{
    public typealias RawValue = UInt32
    public let rawValue: UInt32

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public init?(flags: NSEventModifierFlags) {
        var rawValue: UInt32 = 0

        if flags.contains(NSEventModifierFlags.AlphaShiftKeyMask) { rawValue |= UInt32(Carbon.alphaLock) }
        if flags.contains(NSEventModifierFlags.AlternateKeyMask) { rawValue |= UInt32(Carbon.optionKey) }
        if flags.contains(NSEventModifierFlags.CommandKeyMask) { rawValue |= UInt32(Carbon.cmdKey) }
        if flags.contains(NSEventModifierFlags.ControlKeyMask) { rawValue |= UInt32(Carbon.controlKey) }
        if flags.contains(NSEventModifierFlags.ShiftKeyMask) { rawValue |= UInt32(Carbon.shiftKey) }

        if rawValue == 0 {
            return nil
        } else {
            self = KeyboardModifier(rawValue: rawValue)
        }
    }

    // MARK: -

    public static let AlphaLock = KeyboardModifier(rawValue: UInt32(Carbon.alphaLock))
    public static let CommandKey = KeyboardModifier(rawValue: UInt32(Carbon.cmdKey))
    public static let ControlKey = KeyboardModifier(rawValue: UInt32(Carbon.controlKey))
    public static let OptionKey = KeyboardModifier(rawValue: UInt32(Carbon.optionKey))
    public static let ShiftKey = KeyboardModifier(rawValue: UInt32(Carbon.shiftKey))
}
