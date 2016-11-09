import Foundation

public struct KeyboardHotkey: Equatable
{
    public var key: UInt32
    public var modifier: UInt32

    public init(key: UInt32, modifier: UInt32) {
        self.key = key
        self.modifier = modifier
    }

    public init(key: UInt32, modifier: KeyboardModifier) {
        self.key = key
        self.modifier = modifier.rawValue
    }
}

public func ==(lhs: KeyboardHotkey, rhs: KeyboardHotkey) -> Bool {
    return lhs.key == rhs.key && lhs.modifier == rhs.modifier
}