import Carbon

public struct KeyboardKey
{
    public static let a: CGKeyCode = CGKeyCode(kVK_ANSI_A)
    public static let b: CGKeyCode = CGKeyCode(kVK_ANSI_B)
    public static let c: CGKeyCode = CGKeyCode(kVK_ANSI_C)
    public static let d: CGKeyCode = CGKeyCode(kVK_ANSI_D)
    public static let e: CGKeyCode = CGKeyCode(kVK_ANSI_E)
    public static let f: CGKeyCode = CGKeyCode(kVK_ANSI_F)
    public static let g: CGKeyCode = CGKeyCode(kVK_ANSI_G)
    public static let h: CGKeyCode = CGKeyCode(kVK_ANSI_H)
    public static let i: CGKeyCode = CGKeyCode(kVK_ANSI_I)
    public static let j: CGKeyCode = CGKeyCode(kVK_ANSI_J)
    public static let k: CGKeyCode = CGKeyCode(kVK_ANSI_K)
    public static let l: CGKeyCode = CGKeyCode(kVK_ANSI_L)
    public static let m: CGKeyCode = CGKeyCode(kVK_ANSI_M)
    public static let n: CGKeyCode = CGKeyCode(kVK_ANSI_N)
    public static let o: CGKeyCode = CGKeyCode(kVK_ANSI_O)
    public static let p: CGKeyCode = CGKeyCode(kVK_ANSI_P)
    public static let q: CGKeyCode = CGKeyCode(kVK_ANSI_Q)
    public static let r: CGKeyCode = CGKeyCode(kVK_ANSI_R)
    public static let s: CGKeyCode = CGKeyCode(kVK_ANSI_S)
    public static let t: CGKeyCode = CGKeyCode(kVK_ANSI_T)
    public static let u: CGKeyCode = CGKeyCode(kVK_ANSI_U)
    public static let v: CGKeyCode = CGKeyCode(kVK_ANSI_V)
    public static let w: CGKeyCode = CGKeyCode(kVK_ANSI_W)
    public static let x: CGKeyCode = CGKeyCode(kVK_ANSI_X)
    public static let y: CGKeyCode = CGKeyCode(kVK_ANSI_Y)
    public static let z: CGKeyCode = CGKeyCode(kVK_ANSI_Z)

    public static let zero: CGKeyCode = CGKeyCode(kVK_ANSI_0)
    public static let one: CGKeyCode = CGKeyCode(kVK_ANSI_1)
    public static let two: CGKeyCode = CGKeyCode(kVK_ANSI_2)
    public static let three: CGKeyCode = CGKeyCode(kVK_ANSI_3)
    public static let four: CGKeyCode = CGKeyCode(kVK_ANSI_4)
    public static let five: CGKeyCode = CGKeyCode(kVK_ANSI_5)
    public static let six: CGKeyCode = CGKeyCode(kVK_ANSI_6)
    public static let seven: CGKeyCode = CGKeyCode(kVK_ANSI_7)
    public static let eight: CGKeyCode = CGKeyCode(kVK_ANSI_8)
    public static let nine: CGKeyCode = CGKeyCode(kVK_ANSI_9)

    public static let equal: CGKeyCode = CGKeyCode(kVK_ANSI_Equal)
    public static let minus: CGKeyCode = CGKeyCode(kVK_ANSI_Minus)
    public static let rightBracket: CGKeyCode = CGKeyCode(kVK_ANSI_RightBracket)
    public static let leftBracket: CGKeyCode = CGKeyCode(kVK_ANSI_LeftBracket)
    public static let quote: CGKeyCode = CGKeyCode(kVK_ANSI_Quote)
    public static let semicolon: CGKeyCode = CGKeyCode(kVK_ANSI_Semicolon)
    public static let backslash: CGKeyCode = CGKeyCode(kVK_ANSI_Backslash)
    public static let comma: CGKeyCode = CGKeyCode(kVK_ANSI_Comma)
    public static let slash: CGKeyCode = CGKeyCode(kVK_ANSI_Slash)
    public static let period: CGKeyCode = CGKeyCode(kVK_ANSI_Period)
    public static let grave: CGKeyCode = CGKeyCode(kVK_ANSI_Grave)

    public static let keypadDecimal: CGKeyCode = CGKeyCode(kVK_ANSI_KeypadDecimal)
    public static let keypadMultiply: CGKeyCode = CGKeyCode(kVK_ANSI_KeypadMultiply)
    public static let keypadPlus: CGKeyCode = CGKeyCode(kVK_ANSI_KeypadPlus)
    public static let keypadClear: CGKeyCode = CGKeyCode(kVK_ANSI_KeypadClear)
    public static let keypadDivide: CGKeyCode = CGKeyCode(kVK_ANSI_KeypadDivide)
    public static let keypadEnter: CGKeyCode = CGKeyCode(kVK_ANSI_KeypadEnter)
    public static let keypadMinus: CGKeyCode = CGKeyCode(kVK_ANSI_KeypadMinus)
    public static let keypadEquals: CGKeyCode = CGKeyCode(kVK_ANSI_KeypadEquals)

    public static let keypad0: CGKeyCode = CGKeyCode(kVK_ANSI_Keypad0)
    public static let keypad1: CGKeyCode = CGKeyCode(kVK_ANSI_Keypad1)
    public static let keypad2: CGKeyCode = CGKeyCode(kVK_ANSI_Keypad2)
    public static let keypad3: CGKeyCode = CGKeyCode(kVK_ANSI_Keypad3)
    public static let keypad4: CGKeyCode = CGKeyCode(kVK_ANSI_Keypad4)
    public static let keypad5: CGKeyCode = CGKeyCode(kVK_ANSI_Keypad5)
    public static let keypad6: CGKeyCode = CGKeyCode(kVK_ANSI_Keypad6)
    public static let keypad7: CGKeyCode = CGKeyCode(kVK_ANSI_Keypad7)
    public static let keypad8: CGKeyCode = CGKeyCode(kVK_ANSI_Keypad8)
    public static let keypad9: CGKeyCode = CGKeyCode(kVK_ANSI_Keypad9)

    public static let capsLock: CGKeyCode = CGKeyCode(kVK_CapsLock)
    public static let command: CGKeyCode = CGKeyCode(kVK_Command)
    public static let control: CGKeyCode = CGKeyCode(kVK_Control)
    public static let option: CGKeyCode = CGKeyCode(kVK_Option)
    public static let shift: CGKeyCode = CGKeyCode(kVK_Shift)

    public static let function: CGKeyCode = CGKeyCode(kVK_Function)
    public static let mute: CGKeyCode = CGKeyCode(kVK_Mute)
    public static let volumeDown: CGKeyCode = CGKeyCode(kVK_VolumeDown)
    public static let volumeUp: CGKeyCode = CGKeyCode(kVK_VolumeUp)
    public static let rightControl: CGKeyCode = CGKeyCode(kVK_RightControl)
    public static let rightOption: CGKeyCode = CGKeyCode(kVK_RightOption)
    public static let rightShift: CGKeyCode = CGKeyCode(kVK_RightShift)

    public static let delete: CGKeyCode = CGKeyCode(kVK_Delete)
    public static let downArrow: CGKeyCode = CGKeyCode(kVK_DownArrow)
    public static let end: CGKeyCode = CGKeyCode(kVK_End)
    public static let escape: CGKeyCode = CGKeyCode(kVK_Escape)
    public static let forwardDelete: CGKeyCode = CGKeyCode(kVK_ForwardDelete)
    public static let help: CGKeyCode = CGKeyCode(kVK_Help)
    public static let home: CGKeyCode = CGKeyCode(kVK_Home)
    public static let leftArrow: CGKeyCode = CGKeyCode(kVK_LeftArrow)
    public static let pageDown: CGKeyCode = CGKeyCode(kVK_PageDown)
    public static let pageUp: CGKeyCode = CGKeyCode(kVK_PageUp)
    public static let `return`: CGKeyCode = CGKeyCode(kVK_Return)
    public static let rightArrow: CGKeyCode = CGKeyCode(kVK_RightArrow)
    public static let space: CGKeyCode = CGKeyCode(kVK_Space)
    public static let tab: CGKeyCode = CGKeyCode(kVK_Tab)
    public static let upArrow: CGKeyCode = CGKeyCode(kVK_UpArrow)

    public static let f1: CGKeyCode = CGKeyCode(kVK_F1)
    public static let f2: CGKeyCode = CGKeyCode(kVK_F2)
    public static let f3: CGKeyCode = CGKeyCode(kVK_F3)
    public static let f4: CGKeyCode = CGKeyCode(kVK_F4)
    public static let f5: CGKeyCode = CGKeyCode(kVK_F5)
    public static let f6: CGKeyCode = CGKeyCode(kVK_F6)
    public static let f7: CGKeyCode = CGKeyCode(kVK_F7)
    public static let f8: CGKeyCode = CGKeyCode(kVK_F8)
    public static let f9: CGKeyCode = CGKeyCode(kVK_F9)
    public static let f10: CGKeyCode = CGKeyCode(kVK_F10)
    public static let f11: CGKeyCode = CGKeyCode(kVK_F11)
    public static let f12: CGKeyCode = CGKeyCode(kVK_F12)
    public static let f13: CGKeyCode = CGKeyCode(kVK_F13)
    public static let f14: CGKeyCode = CGKeyCode(kVK_F14)
    public static let f15: CGKeyCode = CGKeyCode(kVK_F15)
    public static let f16: CGKeyCode = CGKeyCode(kVK_F16)
    public static let f17: CGKeyCode = CGKeyCode(kVK_F17)
    public static let f18: CGKeyCode = CGKeyCode(kVK_F18)
    public static let f19: CGKeyCode = CGKeyCode(kVK_F19)
    public static let f20: CGKeyCode = CGKeyCode(kVK_F20)

    // MARK: -

    /*
    Predefined names for special case keys, typically language independent.
    */
    public static let names: [CGKeyCode: String] = [
        KeyboardKey.keypadClear: "⌧",
        KeyboardKey.keypadEnter: "⌅",

        KeyboardKey.delete: "⌫",
        KeyboardKey.downArrow: "↓",
        KeyboardKey.end: "↘",
        KeyboardKey.escape: "⎋",
        KeyboardKey.forwardDelete: "⌦",
        KeyboardKey.help: "?⃝",
        KeyboardKey.home: "↖",
        KeyboardKey.leftArrow: "←",
        KeyboardKey.pageDown: "⇟",
        KeyboardKey.pageUp: "⇞",
        KeyboardKey.return: "↩",
        KeyboardKey.rightArrow: "→",
        KeyboardKey.space: "Space",
        KeyboardKey.tab: "⇥",
        KeyboardKey.upArrow: "↑",

        KeyboardKey.f1: "F1",
        KeyboardKey.f2: "F2",
        KeyboardKey.f3: "F3",
        KeyboardKey.f4: "F4",
        KeyboardKey.f5: "F5",
        KeyboardKey.f6: "F6",
        KeyboardKey.f7: "F7",
        KeyboardKey.f8: "F8",
        KeyboardKey.f9: "F9",
        KeyboardKey.f10: "F10",
        KeyboardKey.f11: "F11",
        KeyboardKey.f12: "F12",
        KeyboardKey.f13: "F13",
        KeyboardKey.f14: "F14",
        KeyboardKey.f15: "F15",
        KeyboardKey.f16: "F16",
        KeyboardKey.f17: "F17",
        KeyboardKey.f18: "F18",
        KeyboardKey.f19: "F19",
        KeyboardKey.f20: "F20"
    ]

    // MARK: -

    /*
    Key name in the current keyboard input source.
    */
    public static func name(for key: CGKeyCode, names: [CGKeyCode: String]? = nil) -> String? {
        let map: [CGKeyCode: String] = names ?? self.names

        if map.keys.contains(key) {
            return map[key]
        }

        let maxStringLength: Int = 4
        var stringBuffer: [UniChar] = [UniChar](repeating: 0, count: maxStringLength)
        var stringLength: Int = 0

        let modifierKeys: UInt32 = 0
        var deadKeys: UInt32 = 0
        let keyboardType: UInt32 = UInt32(LMGetKbdType())

        let source: TISInputSource = TISCopyCurrentASCIICapableKeyboardInputSource().takeRetainedValue()
        let layoutDataPointer: UnsafeMutableRawPointer = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData)
        let layoutData: Data = Unmanaged<CFData>.fromOpaque(UnsafeRawPointer(layoutDataPointer)).takeUnretainedValue() as Data
        let layoutPointer: UnsafePointer<UCKeyboardLayout> = (layoutData as NSData).bytes.bindMemory(to: UCKeyboardLayout.self, capacity: layoutData.count)

        let status: OSStatus = UCKeyTranslate(layoutPointer, key, CGKeyCode(kUCKeyActionDown), modifierKeys, keyboardType, UInt32(kUCKeyTranslateNoDeadKeysMask), &deadKeys, maxStringLength, &stringLength, &stringBuffer)
        guard status == Darwin.noErr else { return nil }

        return String(utf16CodeUnits: stringBuffer, count: stringLength).uppercased()
    }
}