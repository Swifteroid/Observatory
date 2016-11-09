import Foundation
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

    // MARK: -

    public static let AlphaLock = KeyboardModifier(rawValue: UInt32(Carbon.alphaLock))
    public static let CmdKey = KeyboardModifier(rawValue: UInt32(Carbon.cmdKey))
    public static let ControlKey = KeyboardModifier(rawValue: UInt32(Carbon.controlKey))
    public static let OptionKey = KeyboardModifier(rawValue: UInt32(Carbon.optionKey))
    public static let ShiftKey = KeyboardModifier(rawValue: UInt32(Carbon.shiftKey))
}
