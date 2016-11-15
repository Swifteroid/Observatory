import Foundation

public struct KeyboardHotkey: Equatable, Hashable
{
    public var key: UInt16
    public var modifier: UInt32

    // MARK: -

    public var hashValue: Int {
        return Int(UInt64(self.modifier) << 16 | UInt64(self.key))
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
}

public func ==(lhs: KeyboardHotkey, rhs: KeyboardHotkey) -> Bool {
    return lhs.key == rhs.key && lhs.modifier == rhs.modifier
}