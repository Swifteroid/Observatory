import AppKit.NSEvent
import Carbon

public struct KeyboardKey: RawRepresentable {
    public init(rawValue: Int) { self.rawValue = rawValue }
    public init(_ rawValue: Int) { self.init(rawValue: rawValue) }
    public init(_ keyCode: CGKeyCode) { self.init(Int(keyCode)) }
    public init(_ event: NSEvent) { self.init(Int(event.keyCode)) }

    public let rawValue: Int

    public static let a: KeyboardKey = .init(kVK_ANSI_A)
    public static let b: KeyboardKey = .init(kVK_ANSI_B)
    public static let c: KeyboardKey = .init(kVK_ANSI_C)
    public static let d: KeyboardKey = .init(kVK_ANSI_D)
    public static let e: KeyboardKey = .init(kVK_ANSI_E)
    public static let f: KeyboardKey = .init(kVK_ANSI_F)
    public static let g: KeyboardKey = .init(kVK_ANSI_G)
    public static let h: KeyboardKey = .init(kVK_ANSI_H)
    public static let i: KeyboardKey = .init(kVK_ANSI_I)
    public static let j: KeyboardKey = .init(kVK_ANSI_J)
    public static let k: KeyboardKey = .init(kVK_ANSI_K)
    public static let l: KeyboardKey = .init(kVK_ANSI_L)
    public static let m: KeyboardKey = .init(kVK_ANSI_M)
    public static let n: KeyboardKey = .init(kVK_ANSI_N)
    public static let o: KeyboardKey = .init(kVK_ANSI_O)
    public static let p: KeyboardKey = .init(kVK_ANSI_P)
    public static let q: KeyboardKey = .init(kVK_ANSI_Q)
    public static let r: KeyboardKey = .init(kVK_ANSI_R)
    public static let s: KeyboardKey = .init(kVK_ANSI_S)
    public static let t: KeyboardKey = .init(kVK_ANSI_T)
    public static let u: KeyboardKey = .init(kVK_ANSI_U)
    public static let v: KeyboardKey = .init(kVK_ANSI_V)
    public static let w: KeyboardKey = .init(kVK_ANSI_W)
    public static let x: KeyboardKey = .init(kVK_ANSI_X)
    public static let y: KeyboardKey = .init(kVK_ANSI_Y)
    public static let z: KeyboardKey = .init(kVK_ANSI_Z)

    public static let zero: KeyboardKey = .init(kVK_ANSI_0)
    public static let one: KeyboardKey = .init(kVK_ANSI_1)
    public static let two: KeyboardKey = .init(kVK_ANSI_2)
    public static let three: KeyboardKey = .init(kVK_ANSI_3)
    public static let four: KeyboardKey = .init(kVK_ANSI_4)
    public static let five: KeyboardKey = .init(kVK_ANSI_5)
    public static let six: KeyboardKey = .init(kVK_ANSI_6)
    public static let seven: KeyboardKey = .init(kVK_ANSI_7)
    public static let eight: KeyboardKey = .init(kVK_ANSI_8)
    public static let nine: KeyboardKey = .init(kVK_ANSI_9)

    public static let equal: KeyboardKey = .init(kVK_ANSI_Equal)
    public static let minus: KeyboardKey = .init(kVK_ANSI_Minus)
    public static let rightBracket: KeyboardKey = .init(kVK_ANSI_RightBracket)
    public static let leftBracket: KeyboardKey = .init(kVK_ANSI_LeftBracket)
    public static let quote: KeyboardKey = .init(kVK_ANSI_Quote)
    public static let semicolon: KeyboardKey = .init(kVK_ANSI_Semicolon)
    public static let backslash: KeyboardKey = .init(kVK_ANSI_Backslash)
    public static let comma: KeyboardKey = .init(kVK_ANSI_Comma)
    public static let slash: KeyboardKey = .init(kVK_ANSI_Slash)
    public static let period: KeyboardKey = .init(kVK_ANSI_Period)
    public static let grave: KeyboardKey = .init(kVK_ANSI_Grave)

    public static let keypadDecimal: KeyboardKey = .init(kVK_ANSI_KeypadDecimal)
    public static let keypadMultiply: KeyboardKey = .init(kVK_ANSI_KeypadMultiply)
    public static let keypadPlus: KeyboardKey = .init(kVK_ANSI_KeypadPlus)
    public static let keypadClear: KeyboardKey = .init(kVK_ANSI_KeypadClear)
    public static let keypadDivide: KeyboardKey = .init(kVK_ANSI_KeypadDivide)
    public static let keypadEnter: KeyboardKey = .init(kVK_ANSI_KeypadEnter)
    public static let keypadMinus: KeyboardKey = .init(kVK_ANSI_KeypadMinus)
    public static let keypadEquals: KeyboardKey = .init(kVK_ANSI_KeypadEquals)

    public static let keypad0: KeyboardKey = .init(kVK_ANSI_Keypad0)
    public static let keypad1: KeyboardKey = .init(kVK_ANSI_Keypad1)
    public static let keypad2: KeyboardKey = .init(kVK_ANSI_Keypad2)
    public static let keypad3: KeyboardKey = .init(kVK_ANSI_Keypad3)
    public static let keypad4: KeyboardKey = .init(kVK_ANSI_Keypad4)
    public static let keypad5: KeyboardKey = .init(kVK_ANSI_Keypad5)
    public static let keypad6: KeyboardKey = .init(kVK_ANSI_Keypad6)
    public static let keypad7: KeyboardKey = .init(kVK_ANSI_Keypad7)
    public static let keypad8: KeyboardKey = .init(kVK_ANSI_Keypad8)
    public static let keypad9: KeyboardKey = .init(kVK_ANSI_Keypad9)

    public static let capsLock: KeyboardKey = .init(kVK_CapsLock)
    public static let command: KeyboardKey = .init(kVK_Command)
    public static let control: KeyboardKey = .init(kVK_Control)
    public static let option: KeyboardKey = .init(kVK_Option)
    public static let shift: KeyboardKey = .init(kVK_Shift)

    public static let function: KeyboardKey = .init(kVK_Function)
    public static let mute: KeyboardKey = .init(kVK_Mute)
    public static let volumeDown: KeyboardKey = .init(kVK_VolumeDown)
    public static let volumeUp: KeyboardKey = .init(kVK_VolumeUp)
    public static let rightControl: KeyboardKey = .init(kVK_RightControl)
    public static let rightOption: KeyboardKey = .init(kVK_RightOption)
    public static let rightShift: KeyboardKey = .init(kVK_RightShift)

    public static let delete: KeyboardKey = .init(kVK_Delete)
    public static let downArrow: KeyboardKey = .init(kVK_DownArrow)
    public static let end: KeyboardKey = .init(kVK_End)
    public static let escape: KeyboardKey = .init(kVK_Escape)
    public static let forwardDelete: KeyboardKey = .init(kVK_ForwardDelete)
    public static let help: KeyboardKey = .init(kVK_Help)
    public static let home: KeyboardKey = .init(kVK_Home)
    public static let leftArrow: KeyboardKey = .init(kVK_LeftArrow)
    public static let pageDown: KeyboardKey = .init(kVK_PageDown)
    public static let pageUp: KeyboardKey = .init(kVK_PageUp)
    public static let `return`: KeyboardKey = .init(kVK_Return)
    public static let rightArrow: KeyboardKey = .init(kVK_RightArrow)
    public static let space: KeyboardKey = .init(kVK_Space)
    public static let tab: KeyboardKey = .init(kVK_Tab)
    public static let upArrow: KeyboardKey = .init(kVK_UpArrow)

    public static let f1: KeyboardKey = .init(kVK_F1)
    public static let f2: KeyboardKey = .init(kVK_F2)
    public static let f3: KeyboardKey = .init(kVK_F3)
    public static let f4: KeyboardKey = .init(kVK_F4)
    public static let f5: KeyboardKey = .init(kVK_F5)
    public static let f6: KeyboardKey = .init(kVK_F6)
    public static let f7: KeyboardKey = .init(kVK_F7)
    public static let f8: KeyboardKey = .init(kVK_F8)
    public static let f9: KeyboardKey = .init(kVK_F9)
    public static let f10: KeyboardKey = .init(kVK_F10)
    public static let f11: KeyboardKey = .init(kVK_F11)
    public static let f12: KeyboardKey = .init(kVK_F12)
    public static let f13: KeyboardKey = .init(kVK_F13)
    public static let f14: KeyboardKey = .init(kVK_F14)
    public static let f15: KeyboardKey = .init(kVK_F15)
    public static let f16: KeyboardKey = .init(kVK_F16)
    public static let f17: KeyboardKey = .init(kVK_F17)
    public static let f18: KeyboardKey = .init(kVK_F18)
    public static let f19: KeyboardKey = .init(kVK_F19)
    public static let f20: KeyboardKey = .init(kVK_F20)

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
        .f20: "F20",
    ]

    /// Key name in the current keyboard input source.
    public var name: String? {
        self.name(names: nil)
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

extension KeyboardKey: Equatable, Hashable {
    public var hashValue: Int { Int(self.rawValue) }
}

extension KeyboardKey: CustomStringConvertible {
    public var description: String {
        self.name ?? ""
    }
}
