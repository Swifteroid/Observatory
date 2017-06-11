import AppKit.NSEvent
import Foundation

public struct KeyboardHotkey: Equatable, Hashable
{
    public var key: UInt16
    public var modifier: UInt32

    public var value: UInt64 {
        get {
            return UInt64(self.modifier) << 16 | UInt64(self.key)
        }
        set {
            self.key = UInt16(truncatingBitPattern: newValue)
            self.modifier = UInt32(truncatingBitPattern: newValue >> 16)
        }
    }

    // MARK: -

    public var hashValue: Int {
        return Int(self.value)
    }

    // MARK: -

    public init(key: UInt16, modifier: UInt32) {
        self.key = key
        self.modifier = modifier
    }

    public init(key: UInt16, modifier: KeyboardModifier) {
        self.key = key
        self.modifier = modifier.rawValue
    }

    public init(value: UInt64) {
        self.key = UInt16(truncatingBitPattern: value)
        self.modifier = UInt32(truncatingBitPattern: value >> 16)
    }

    public init?(event: NSEvent) {
        if event.type == .keyUp || event.type == .keyDown || event.type == .flagsChanged {
            self.init(key: event.keyCode, modifier: KeyboardModifier(flags: event.modifierFlags))
        } else {
            return nil
        }
    }
}

public func ==(lhs: KeyboardHotkey, rhs: KeyboardHotkey) -> Bool {
    return lhs.key == rhs.key && lhs.modifier == rhs.modifier
}

// MARK: -

extension KeyboardHotkey: CustomStringConvertible
{
    public var description: String {
        return "\(KeyboardModifier.name(for: self.modifier) ?? "")\(KeyboardKey.name(for: self.key) ?? "")"
    }
}