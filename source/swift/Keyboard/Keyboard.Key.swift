import Foundation
import Carbon

public struct KeyboardKey
{
    public static let A: UInt32 = UInt32(kVK_ANSI_A)
    public static let B: UInt32 = UInt32(kVK_ANSI_B)
    public static let C: UInt32 = UInt32(kVK_ANSI_C)
    public static let D: UInt32 = UInt32(kVK_ANSI_D)
    public static let E: UInt32 = UInt32(kVK_ANSI_E)
    public static let F: UInt32 = UInt32(kVK_ANSI_F)
    public static let G: UInt32 = UInt32(kVK_ANSI_G)
    public static let H: UInt32 = UInt32(kVK_ANSI_H)
    public static let I: UInt32 = UInt32(kVK_ANSI_I)
    public static let J: UInt32 = UInt32(kVK_ANSI_J)
    public static let K: UInt32 = UInt32(kVK_ANSI_K)
    public static let L: UInt32 = UInt32(kVK_ANSI_L)
    public static let M: UInt32 = UInt32(kVK_ANSI_M)
    public static let N: UInt32 = UInt32(kVK_ANSI_N)
    public static let O: UInt32 = UInt32(kVK_ANSI_O)
    public static let P: UInt32 = UInt32(kVK_ANSI_P)
    public static let Q: UInt32 = UInt32(kVK_ANSI_Q)
    public static let R: UInt32 = UInt32(kVK_ANSI_R)
    public static let S: UInt32 = UInt32(kVK_ANSI_S)
    public static let T: UInt32 = UInt32(kVK_ANSI_T)
    public static let U: UInt32 = UInt32(kVK_ANSI_U)
    public static let V: UInt32 = UInt32(kVK_ANSI_V)
    public static let W: UInt32 = UInt32(kVK_ANSI_W)
    public static let X: UInt32 = UInt32(kVK_ANSI_X)
    public static let Y: UInt32 = UInt32(kVK_ANSI_Y)
    public static let Z: UInt32 = UInt32(kVK_ANSI_Z)

    public static let Zero: UInt32 = UInt32(kVK_ANSI_0)
    public static let One: UInt32 = UInt32(kVK_ANSI_1)
    public static let Two: UInt32 = UInt32(kVK_ANSI_2)
    public static let Three: UInt32 = UInt32(kVK_ANSI_3)
    public static let Four: UInt32 = UInt32(kVK_ANSI_4)
    public static let Five: UInt32 = UInt32(kVK_ANSI_5)
    public static let Six: UInt32 = UInt32(kVK_ANSI_6)
    public static let Seven: UInt32 = UInt32(kVK_ANSI_7)
    public static let Eight: UInt32 = UInt32(kVK_ANSI_8)
    public static let Nine: UInt32 = UInt32(kVK_ANSI_9)

    public static let Equal = UInt32(kVK_ANSI_Equal)
    public static let Minus = UInt32(kVK_ANSI_Minus)
    public static let RightBracket = UInt32(kVK_ANSI_RightBracket)
    public static let LeftBracket = UInt32(kVK_ANSI_LeftBracket)
    public static let Quote = UInt32(kVK_ANSI_Quote)
    public static let Semicolon = UInt32(kVK_ANSI_Semicolon)
    public static let Backslash = UInt32(kVK_ANSI_Backslash)
    public static let Comma = UInt32(kVK_ANSI_Comma)
    public static let Slash = UInt32(kVK_ANSI_Slash)
    public static let Period = UInt32(kVK_ANSI_Period)
    public static let Grave = UInt32(kVK_ANSI_Grave)

    public static let KeypadDecimal = UInt32(kVK_ANSI_KeypadDecimal)
    public static let KeypadMultiply = UInt32(kVK_ANSI_KeypadMultiply)
    public static let KeypadPlus = UInt32(kVK_ANSI_KeypadPlus)
    public static let KeypadClear = UInt32(kVK_ANSI_KeypadClear)
    public static let KeypadDivide = UInt32(kVK_ANSI_KeypadDivide)
    public static let KeypadEnter = UInt32(kVK_ANSI_KeypadEnter)
    public static let KeypadMinus = UInt32(kVK_ANSI_KeypadMinus)
    public static let KeypadEquals = UInt32(kVK_ANSI_KeypadEquals)

    public static let Keypad0 = UInt32(kVK_ANSI_Keypad0)
    public static let Keypad1 = UInt32(kVK_ANSI_Keypad1)
    public static let Keypad2 = UInt32(kVK_ANSI_Keypad2)
    public static let Keypad3 = UInt32(kVK_ANSI_Keypad3)
    public static let Keypad4 = UInt32(kVK_ANSI_Keypad4)
    public static let Keypad5 = UInt32(kVK_ANSI_Keypad5)
    public static let Keypad6 = UInt32(kVK_ANSI_Keypad6)
    public static let Keypad7 = UInt32(kVK_ANSI_Keypad7)
    public static let Keypad8 = UInt32(kVK_ANSI_Keypad8)
    public static let Keypad9 = UInt32(kVK_ANSI_Keypad9)

    public static let CapsLock = UInt32(kVK_CapsLock)
    public static let Command = UInt32(kVK_Command)
    public static let Control = UInt32(kVK_Control)
    public static let Option = UInt32(kVK_Option)
    public static let Shift = UInt32(kVK_Shift)

    public static let Function = UInt32(kVK_Function)
    public static let Mute = UInt32(kVK_Mute)
    public static let VolumeDown = UInt32(kVK_VolumeDown)
    public static let VolumeUp = UInt32(kVK_VolumeUp)
    public static let RightControl = UInt32(kVK_RightControl)
    public static let RightOption = UInt32(kVK_RightOption)
    public static let RightShift = UInt32(kVK_RightShift)

    public static let Delete = UInt32(kVK_Delete)
    public static let DownArrow = UInt32(kVK_DownArrow)
    public static let End = UInt32(kVK_End)
    public static let Escape = UInt32(kVK_Escape)
    public static let ForwardDelete = UInt32(kVK_ForwardDelete)
    public static let Help = UInt32(kVK_Help)
    public static let Home = UInt32(kVK_Home)
    public static let LeftArrow = UInt32(kVK_LeftArrow)
    public static let PageDown = UInt32(kVK_PageDown)
    public static let PageUp = UInt32(kVK_PageUp)
    public static let Return = UInt32(kVK_Return)
    public static let RightArrow = UInt32(kVK_RightArrow)
    public static let Space = UInt32(kVK_Space)
    public static let Tab = UInt32(kVK_Tab)
    public static let UpArrow = UInt32(kVK_UpArrow)

    public static let F1 = UInt32(kVK_F1)
    public static let F2 = UInt32(kVK_F2)
    public static let F3 = UInt32(kVK_F3)
    public static let F4 = UInt32(kVK_F4)
    public static let F5 = UInt32(kVK_F5)
    public static let F6 = UInt32(kVK_F6)
    public static let F7 = UInt32(kVK_F7)
    public static let F8 = UInt32(kVK_F8)
    public static let F9 = UInt32(kVK_F9)
    public static let F10 = UInt32(kVK_F10)
    public static let F11 = UInt32(kVK_F11)
    public static let F12 = UInt32(kVK_F12)
    public static let F13 = UInt32(kVK_F13)
    public static let F14 = UInt32(kVK_F14)
    public static let F15 = UInt32(kVK_F15)
    public static let F16 = UInt32(kVK_F16)
    public static let F17 = UInt32(kVK_F17)
    public static let F18 = UInt32(kVK_F18)
    public static let F19 = UInt32(kVK_F19)
    public static let F20 = UInt32(kVK_F20)

    // MARK: -

    public static let names: [UInt32: String] = [
        KeyboardKey.KeypadClear: "⌧",
        KeyboardKey.KeypadEnter: "⌅",

        KeyboardKey.Delete: "⌫",
        KeyboardKey.DownArrow: "↓",
        KeyboardKey.End: "↘",
        KeyboardKey.Escape: "⎋",
        KeyboardKey.ForwardDelete: "⌦",
        KeyboardKey.Help: "?⃝",
        KeyboardKey.Home: "↖",
        KeyboardKey.LeftArrow: "←",
        KeyboardKey.PageDown: "⇟",
        KeyboardKey.PageUp: "⇞",
        KeyboardKey.Return: "↩",
        KeyboardKey.RightArrow: "→",
        KeyboardKey.Space: "Space",
        KeyboardKey.Tab: "⇥",
        KeyboardKey.UpArrow: "↑",

        KeyboardKey.F1: "F1",
        KeyboardKey.F2: "F2",
        KeyboardKey.F3: "F3",
        KeyboardKey.F4: "F4",
        KeyboardKey.F5: "F5",
        KeyboardKey.F6: "F6",
        KeyboardKey.F7: "F7",
        KeyboardKey.F8: "F8",
        KeyboardKey.F9: "F9",
        KeyboardKey.F10: "F10",
        KeyboardKey.F11: "F11",
        KeyboardKey.F12: "F12",
        KeyboardKey.F13: "F13",
        KeyboardKey.F14: "F14",
        KeyboardKey.F15: "F15",
        KeyboardKey.F16: "F16",
        KeyboardKey.F17: "F17",
        KeyboardKey.F18: "F18",
        KeyboardKey.F19: "F19",
        KeyboardKey.F20: "F20"
    ]

    // MARK: -

    public static func getName(key: UInt32, names: [UInt32: String]? = nil) -> String? {
        if let map: [UInt32: String] = names ?? self.names where map.keys.contains(key) {
            return map[key]
        }

        let maxStringLength: Int = 4
        var stringBuffer: [UniChar] = [UniChar](count: maxStringLength, repeatedValue: 0)
        var stringLength: Int = 0

        let modifierKeys: UInt32 = 0
        var deadKeys: UInt32 = 0
        let keyboardType: UInt32 = UInt32(LMGetKbdType())

        let source: TISInputSource = TISCopyCurrentASCIICapableKeyboardInputSource().takeRetainedValue()
        let layoutDataPointer: UnsafeMutablePointer<Void> = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData)
        let layoutData: NSData = Unmanaged<CFData>.fromOpaque(COpaquePointer(layoutDataPointer)).takeUnretainedValue() as NSData
        let layoutPointer: UnsafePointer<UCKeyboardLayout> = UnsafePointer(layoutData.bytes)

        guard let status: OSStatus = UCKeyTranslate(layoutPointer, UInt16(key), UInt16(kUCKeyActionDown), modifierKeys, keyboardType, UInt32(kUCKeyTranslateNoDeadKeysMask), &deadKeys, maxStringLength, &stringLength, &stringBuffer) where status == Darwin.noErr else {
            return nil
        }

        return String(utf16CodeUnits: stringBuffer, count: stringLength).uppercaseString
    }
}