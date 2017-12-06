import AppKit.NSEvent
import Carbon

public struct KeyboardKey: RawRepresentable
{
    public init(rawValue: Int) { self.rawValue = rawValue }
    public init(_ rawValue: Int) { self.init(rawValue: rawValue) }
    public init(_ keyCode: CGKeyCode) { self.init(Int(keyCode)) }
    public init(_ event: NSEvent) { self.init(Int(event.keyCode)) }

    public let rawValue: Int

    public static let a = KeyboardKey(rawValue: kVK_ANSI_A)
    public static let b = KeyboardKey(rawValue: kVK_ANSI_B)
    public static let c = KeyboardKey(rawValue: kVK_ANSI_C)
    public static let d = KeyboardKey(rawValue: kVK_ANSI_D)
    public static let e = KeyboardKey(rawValue: kVK_ANSI_E)
    public static let f = KeyboardKey(rawValue: kVK_ANSI_F)
    public static let g = KeyboardKey(rawValue: kVK_ANSI_G)
    public static let h = KeyboardKey(rawValue: kVK_ANSI_H)
    public static let i = KeyboardKey(rawValue: kVK_ANSI_I)
    public static let j = KeyboardKey(rawValue: kVK_ANSI_J)
    public static let k = KeyboardKey(rawValue: kVK_ANSI_K)
    public static let l = KeyboardKey(rawValue: kVK_ANSI_L)
    public static let m = KeyboardKey(rawValue: kVK_ANSI_M)
    public static let n = KeyboardKey(rawValue: kVK_ANSI_N)
    public static let o = KeyboardKey(rawValue: kVK_ANSI_O)
    public static let p = KeyboardKey(rawValue: kVK_ANSI_P)
    public static let q = KeyboardKey(rawValue: kVK_ANSI_Q)
    public static let r = KeyboardKey(rawValue: kVK_ANSI_R)
    public static let s = KeyboardKey(rawValue: kVK_ANSI_S)
    public static let t = KeyboardKey(rawValue: kVK_ANSI_T)
    public static let u = KeyboardKey(rawValue: kVK_ANSI_U)
    public static let v = KeyboardKey(rawValue: kVK_ANSI_V)
    public static let w = KeyboardKey(rawValue: kVK_ANSI_W)
    public static let x = KeyboardKey(rawValue: kVK_ANSI_X)
    public static let y = KeyboardKey(rawValue: kVK_ANSI_Y)
    public static let z = KeyboardKey(rawValue: kVK_ANSI_Z)

    public static let zero = KeyboardKey(rawValue: kVK_ANSI_0)
    public static let one = KeyboardKey(rawValue: kVK_ANSI_1)
    public static let two = KeyboardKey(rawValue: kVK_ANSI_2)
    public static let three = KeyboardKey(rawValue: kVK_ANSI_3)
    public static let four = KeyboardKey(rawValue: kVK_ANSI_4)
    public static let five = KeyboardKey(rawValue: kVK_ANSI_5)
    public static let six = KeyboardKey(rawValue: kVK_ANSI_6)
    public static let seven = KeyboardKey(rawValue: kVK_ANSI_7)
    public static let eight = KeyboardKey(rawValue: kVK_ANSI_8)
    public static let nine = KeyboardKey(rawValue: kVK_ANSI_9)

    public static let equal = KeyboardKey(rawValue: kVK_ANSI_Equal)
    public static let minus = KeyboardKey(rawValue: kVK_ANSI_Minus)
    public static let rightBracket = KeyboardKey(rawValue: kVK_ANSI_RightBracket)
    public static let leftBracket = KeyboardKey(rawValue: kVK_ANSI_LeftBracket)
    public static let quote = KeyboardKey(rawValue: kVK_ANSI_Quote)
    public static let semicolon = KeyboardKey(rawValue: kVK_ANSI_Semicolon)
    public static let backslash = KeyboardKey(rawValue: kVK_ANSI_Backslash)
    public static let comma = KeyboardKey(rawValue: kVK_ANSI_Comma)
    public static let slash = KeyboardKey(rawValue: kVK_ANSI_Slash)
    public static let period = KeyboardKey(rawValue: kVK_ANSI_Period)
    public static let grave = KeyboardKey(rawValue: kVK_ANSI_Grave)

    public static let keypadDecimal = KeyboardKey(rawValue: kVK_ANSI_KeypadDecimal)
    public static let keypadMultiply = KeyboardKey(rawValue: kVK_ANSI_KeypadMultiply)
    public static let keypadPlus = KeyboardKey(rawValue: kVK_ANSI_KeypadPlus)
    public static let keypadClear = KeyboardKey(rawValue: kVK_ANSI_KeypadClear)
    public static let keypadDivide = KeyboardKey(rawValue: kVK_ANSI_KeypadDivide)
    public static let keypadEnter = KeyboardKey(rawValue: kVK_ANSI_KeypadEnter)
    public static let keypadMinus = KeyboardKey(rawValue: kVK_ANSI_KeypadMinus)
    public static let keypadEquals = KeyboardKey(rawValue: kVK_ANSI_KeypadEquals)

    public static let keypad0 = KeyboardKey(rawValue: kVK_ANSI_Keypad0)
    public static let keypad1 = KeyboardKey(rawValue: kVK_ANSI_Keypad1)
    public static let keypad2 = KeyboardKey(rawValue: kVK_ANSI_Keypad2)
    public static let keypad3 = KeyboardKey(rawValue: kVK_ANSI_Keypad3)
    public static let keypad4 = KeyboardKey(rawValue: kVK_ANSI_Keypad4)
    public static let keypad5 = KeyboardKey(rawValue: kVK_ANSI_Keypad5)
    public static let keypad6 = KeyboardKey(rawValue: kVK_ANSI_Keypad6)
    public static let keypad7 = KeyboardKey(rawValue: kVK_ANSI_Keypad7)
    public static let keypad8 = KeyboardKey(rawValue: kVK_ANSI_Keypad8)
    public static let keypad9 = KeyboardKey(rawValue: kVK_ANSI_Keypad9)

    public static let capsLock = KeyboardKey(rawValue: kVK_CapsLock)
    public static let command = KeyboardKey(rawValue: kVK_Command)
    public static let control = KeyboardKey(rawValue: kVK_Control)
    public static let option = KeyboardKey(rawValue: kVK_Option)
    public static let shift = KeyboardKey(rawValue: kVK_Shift)

    public static let function = KeyboardKey(rawValue: kVK_Function)
    public static let mute = KeyboardKey(rawValue: kVK_Mute)
    public static let volumeDown = KeyboardKey(rawValue: kVK_VolumeDown)
    public static let volumeUp = KeyboardKey(rawValue: kVK_VolumeUp)
    public static let rightControl = KeyboardKey(rawValue: kVK_RightControl)
    public static let rightOption = KeyboardKey(rawValue: kVK_RightOption)
    public static let rightShift = KeyboardKey(rawValue: kVK_RightShift)

    public static let delete = KeyboardKey(rawValue: kVK_Delete)
    public static let downArrow = KeyboardKey(rawValue: kVK_DownArrow)
    public static let end = KeyboardKey(rawValue: kVK_End)
    public static let escape = KeyboardKey(rawValue: kVK_Escape)
    public static let forwardDelete = KeyboardKey(rawValue: kVK_ForwardDelete)
    public static let help = KeyboardKey(rawValue: kVK_Help)
    public static let home = KeyboardKey(rawValue: kVK_Home)
    public static let leftArrow = KeyboardKey(rawValue: kVK_LeftArrow)
    public static let pageDown = KeyboardKey(rawValue: kVK_PageDown)
    public static let pageUp = KeyboardKey(rawValue: kVK_PageUp)
    public static let `return` = KeyboardKey(rawValue: kVK_Return)
    public static let rightArrow = KeyboardKey(rawValue: kVK_RightArrow)
    public static let space = KeyboardKey(rawValue: kVK_Space)
    public static let tab = KeyboardKey(rawValue: kVK_Tab)
    public static let upArrow = KeyboardKey(rawValue: kVK_UpArrow)

    public static let f1 = KeyboardKey(rawValue: kVK_F1)
    public static let f2 = KeyboardKey(rawValue: kVK_F2)
    public static let f3 = KeyboardKey(rawValue: kVK_F3)
    public static let f4 = KeyboardKey(rawValue: kVK_F4)
    public static let f5 = KeyboardKey(rawValue: kVK_F5)
    public static let f6 = KeyboardKey(rawValue: kVK_F6)
    public static let f7 = KeyboardKey(rawValue: kVK_F7)
    public static let f8 = KeyboardKey(rawValue: kVK_F8)
    public static let f9 = KeyboardKey(rawValue: kVK_F9)
    public static let f10 = KeyboardKey(rawValue: kVK_F10)
    public static let f11 = KeyboardKey(rawValue: kVK_F11)
    public static let f12 = KeyboardKey(rawValue: kVK_F12)
    public static let f13 = KeyboardKey(rawValue: kVK_F13)
    public static let f14 = KeyboardKey(rawValue: kVK_F14)
    public static let f15 = KeyboardKey(rawValue: kVK_F15)
    public static let f16 = KeyboardKey(rawValue: kVK_F16)
    public static let f17 = KeyboardKey(rawValue: kVK_F17)
    public static let f18 = KeyboardKey(rawValue: kVK_F18)
    public static let f19 = KeyboardKey(rawValue: kVK_F19)
    public static let f20 = KeyboardKey(rawValue: kVK_F20)

    // MARK: -

    /// Predefined names for special case keys, typically language independent.

    public static let names: [KeyboardKey: String] = [
        .keypadClear: "⌧",
        .keypadEnter: "⌅",

        .delete: "⌫",
        .downArrow: "↓",
        .end: "↘",
        .escape: "⎋",
        .forwardDelete: "⌦",
        .help: "?⃝",
        .home: "↖",
        .leftArrow: "←",
        .pageDown: "⇟",
        .pageUp: "⇞",
        .return: "↩",
        .rightArrow: "→",
        .space: "Space",
        .tab: "⇥",
        .upArrow: "↑",

        .f1: "F1",
        .f2: "F2",
        .f3: "F3",
        .f4: "F4",
        .f5: "F5",
        .f6: "F6",
        .f7: "F7",
        .f8: "F8",
        .f9: "F9",
        .f10: "F10",
        .f11: "F11",
        .f12: "F12",
        .f13: "F13",
        .f14: "F14",
        .f15: "F15",
        .f16: "F16",
        .f17: "F17",
        .f18: "F18",
        .f19: "F19",
        .f20: "F20"
    ]

    // MARK: -

    /// Key name in the current keyboard input source.

    public var name: String? {
        return self.name(names: nil)
    }

    public func name(names: [KeyboardKey: String]?) -> String? {
        if let name: String = names?[self] ?? type(of: self).names[self] { return name }
        guard let layout: UnsafePointer<UCKeyboardLayout> = type(of: self).layout else { return nil }

        let maxStringLength: Int = 4
        var stringBuffer: [UniChar] = [UniChar](repeating: 0, count: maxStringLength)
        var stringLength: Int = 0

        let modifierKeys: UInt32 = 0
        var deadKeys: UInt32 = 0
        let keyboardType: UInt32 = UInt32(LMGetKbdType())

        let status: OSStatus = UCKeyTranslate(layout, CGKeyCode(self.rawValue), CGKeyCode(kUCKeyActionDown), modifierKeys, keyboardType, UInt32(kUCKeyTranslateNoDeadKeysMask), &deadKeys, maxStringLength, &stringLength, &stringBuffer)
        guard status == Darwin.noErr else { return nil }

        return String(utf16CodeUnits: stringBuffer, count: stringLength).uppercased()
    }

    /// Current unicode keyboard layout, with some great insight from https://jongampark.wordpress.com/2015/07/17.

    private static var layout: UnsafePointer<UCKeyboardLayout>? {
        let data: NSData

        // What is interesting is that kTISPropertyUnicodeKeyLayoutData is still used when it queries last ASCII capable keyboard. It 
        // is TISCopyCurrentASCIICapableKeyboardLayoutInputSource() not TISCopyCurrentASCIICapableKeyboardInputSource() to call. The latter 
        // does not guarantee that it would return an keyboard input with a layout.

        if let pointer = TISGetInputSourceProperty(TISCopyCurrentKeyboardInputSource().takeUnretainedValue(), kTISPropertyUnicodeKeyLayoutData) {
            data = unsafeBitCast(pointer, to: CFData.self) as NSData
        } else if let pointer = TISGetInputSourceProperty(TISCopyCurrentASCIICapableKeyboardLayoutInputSource().takeUnretainedValue(), kTISPropertyUnicodeKeyLayoutData) {
            data = unsafeBitCast(pointer, to: CFData.self) as NSData
        } else {
            return nil
        }

        return data.bytes.bindMemory(to: UCKeyboardLayout.self, capacity: data.length)
    }
}

extension KeyboardKey: Equatable, Hashable
{
    public var hashValue: Int { return Int(self.rawValue) }
}

extension KeyboardKey: CustomStringConvertible
{
    public var description: String {
        return self.name ?? ""
    }
}