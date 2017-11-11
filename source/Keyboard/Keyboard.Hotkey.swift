import AppKit.NSEvent
import Foundation

public struct KeyboardHotkey: RawRepresentable
{
    public init(rawValue: Int) {
        self.init(key: KeyboardKey(UInt16(truncatingIfNeeded: rawValue)), modifier: KeyboardModifier(rawValue: Int(truncatingIfNeeded: rawValue >> 16)))
    }

    public init(key: KeyboardKey, modifier: KeyboardModifier) {
        self.key = key
        self.modifier = modifier
    }

    public init(_ rawValue: Int) {
        self.init(rawValue: rawValue)
    }

    public init?(_ event: NSEvent) {
        if event.type == .keyUp || event.type == .keyDown || event.type == .flagsChanged {
            self.init(key: KeyboardKey(event), modifier: KeyboardModifier(event))
        } else {
            return nil
        }
    }

    // MARK: -

    public var key: KeyboardKey
    public var modifier: KeyboardModifier
    public var rawValue: Int { return self.modifier.rawValue << 16 | self.key.rawValue }
}

extension KeyboardHotkey: Equatable, Hashable
{
    public var hashValue: Int { return Int(self.rawValue) }
}

extension KeyboardHotkey: CustomStringConvertible
{
    public var description: String {
        return "\(self.modifier.name ?? "")\(self.key.name ?? "")"
    }
}