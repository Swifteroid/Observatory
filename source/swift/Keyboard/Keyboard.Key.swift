import Foundation
import Carbon

public struct KeyboardKey
{
    public static let A: UInt16 = UInt16(kVK_ANSI_A)
    public static let B: UInt16 = UInt16(kVK_ANSI_B)
    public static let C: UInt16 = UInt16(kVK_ANSI_C)
    public static let D: UInt16 = UInt16(kVK_ANSI_D)
    public static let E: UInt16 = UInt16(kVK_ANSI_E)
    public static let F: UInt16 = UInt16(kVK_ANSI_F)
    public static let G: UInt16 = UInt16(kVK_ANSI_G)
    public static let H: UInt16 = UInt16(kVK_ANSI_H)
    public static let I: UInt16 = UInt16(kVK_ANSI_I)
    public static let J: UInt16 = UInt16(kVK_ANSI_J)
    public static let K: UInt16 = UInt16(kVK_ANSI_K)
    public static let L: UInt16 = UInt16(kVK_ANSI_L)
    public static let M: UInt16 = UInt16(kVK_ANSI_M)
    public static let N: UInt16 = UInt16(kVK_ANSI_N)
    public static let O: UInt16 = UInt16(kVK_ANSI_O)
    public static let P: UInt16 = UInt16(kVK_ANSI_P)
    public static let Q: UInt16 = UInt16(kVK_ANSI_Q)
    public static let R: UInt16 = UInt16(kVK_ANSI_R)
    public static let S: UInt16 = UInt16(kVK_ANSI_S)
    public static let T: UInt16 = UInt16(kVK_ANSI_T)
    public static let U: UInt16 = UInt16(kVK_ANSI_U)
    public static let V: UInt16 = UInt16(kVK_ANSI_V)
    public static let W: UInt16 = UInt16(kVK_ANSI_W)
    public static let X: UInt16 = UInt16(kVK_ANSI_X)
    public static let Y: UInt16 = UInt16(kVK_ANSI_Y)
    public static let Z: UInt16 = UInt16(kVK_ANSI_Z)

    public static let Zero: UInt16 = UInt16(kVK_ANSI_0)
    public static let One: UInt16 = UInt16(kVK_ANSI_1)
    public static let Two: UInt16 = UInt16(kVK_ANSI_2)
    public static let Three: UInt16 = UInt16(kVK_ANSI_3)
    public static let Four: UInt16 = UInt16(kVK_ANSI_4)
    public static let Five: UInt16 = UInt16(kVK_ANSI_5)
    public static let Six: UInt16 = UInt16(kVK_ANSI_6)
    public static let Seven: UInt16 = UInt16(kVK_ANSI_7)
    public static let Eight: UInt16 = UInt16(kVK_ANSI_8)
    public static let Nine: UInt16 = UInt16(kVK_ANSI_9)

    public static let Equal: UInt16 = UInt16(kVK_ANSI_Equal)
    public static let Minus: UInt16 = UInt16(kVK_ANSI_Minus)
    public static let RightBracket: UInt16 = UInt16(kVK_ANSI_RightBracket)
    public static let LeftBracket: UInt16 = UInt16(kVK_ANSI_LeftBracket)
    public static let Quote: UInt16 = UInt16(kVK_ANSI_Quote)
    public static let Semicolon: UInt16 = UInt16(kVK_ANSI_Semicolon)
    public static let Backslash: UInt16 = UInt16(kVK_ANSI_Backslash)
    public static let Comma: UInt16 = UInt16(kVK_ANSI_Comma)
    public static let Slash: UInt16 = UInt16(kVK_ANSI_Slash)
    public static let Period: UInt16 = UInt16(kVK_ANSI_Period)
    public static let Grave: UInt16 = UInt16(kVK_ANSI_Grave)

    public static let KeypadDecimal: UInt16 = UInt16(kVK_ANSI_KeypadDecimal)
    public static let KeypadMultiply: UInt16 = UInt16(kVK_ANSI_KeypadMultiply)
    public static let KeypadPlus: UInt16 = UInt16(kVK_ANSI_KeypadPlus)
    public static let KeypadClear: UInt16 = UInt16(kVK_ANSI_KeypadClear)
    public static let KeypadDivide: UInt16 = UInt16(kVK_ANSI_KeypadDivide)
    public static let KeypadEnter: UInt16 = UInt16(kVK_ANSI_KeypadEnter)
    public static let KeypadMinus: UInt16 = UInt16(kVK_ANSI_KeypadMinus)
    public static let KeypadEquals: UInt16 = UInt16(kVK_ANSI_KeypadEquals)

    public static let Keypad0: UInt16 = UInt16(kVK_ANSI_Keypad0)
    public static let Keypad1: UInt16 = UInt16(kVK_ANSI_Keypad1)
    public static let Keypad2: UInt16 = UInt16(kVK_ANSI_Keypad2)
    public static let Keypad3: UInt16 = UInt16(kVK_ANSI_Keypad3)
    public static let Keypad4: UInt16 = UInt16(kVK_ANSI_Keypad4)
    public static let Keypad5: UInt16 = UInt16(kVK_ANSI_Keypad5)
    public static let Keypad6: UInt16 = UInt16(kVK_ANSI_Keypad6)
    public static let Keypad7: UInt16 = UInt16(kVK_ANSI_Keypad7)
    public static let Keypad8: UInt16 = UInt16(kVK_ANSI_Keypad8)
    public static let Keypad9: UInt16 = UInt16(kVK_ANSI_Keypad9)

    public static let CapsLock: UInt16 = UInt16(kVK_CapsLock)
    public static let Command: UInt16 = UInt16(kVK_Command)
    public static let Control: UInt16 = UInt16(kVK_Control)
    public static let Option: UInt16 = UInt16(kVK_Option)
    public static let Shift: UInt16 = UInt16(kVK_Shift)

    public static let Function: UInt16 = UInt16(kVK_Function)
    public static let Mute: UInt16 = UInt16(kVK_Mute)
    public static let VolumeDown: UInt16 = UInt16(kVK_VolumeDown)
    public static let VolumeUp: UInt16 = UInt16(kVK_VolumeUp)
    public static let RightControl: UInt16 = UInt16(kVK_RightControl)
    public static let RightOption: UInt16 = UInt16(kVK_RightOption)
    public static let RightShift: UInt16 = UInt16(kVK_RightShift)

    public static let Delete: UInt16 = UInt16(kVK_Delete)
    public static let DownArrow: UInt16 = UInt16(kVK_DownArrow)
    public static let End: UInt16 = UInt16(kVK_End)
    public static let Escape: UInt16 = UInt16(kVK_Escape)
    public static let ForwardDelete: UInt16 = UInt16(kVK_ForwardDelete)
    public static let Help: UInt16 = UInt16(kVK_Help)
    public static let Home: UInt16 = UInt16(kVK_Home)
    public static let LeftArrow: UInt16 = UInt16(kVK_LeftArrow)
    public static let PageDown: UInt16 = UInt16(kVK_PageDown)
    public static let PageUp: UInt16 = UInt16(kVK_PageUp)
    public static let Return: UInt16 = UInt16(kVK_Return)
    public static let RightArrow: UInt16 = UInt16(kVK_RightArrow)
    public static let Space: UInt16 = UInt16(kVK_Space)
    public static let Tab: UInt16 = UInt16(kVK_Tab)
    public static let UpArrow: UInt16 = UInt16(kVK_UpArrow)

    public static let F1: UInt16 = UInt16(kVK_F1)
    public static let F2: UInt16 = UInt16(kVK_F2)
    public static let F3: UInt16 = UInt16(kVK_F3)
    public static let F4: UInt16 = UInt16(kVK_F4)
    public static let F5: UInt16 = UInt16(kVK_F5)
    public static let F6: UInt16 = UInt16(kVK_F6)
    public static let F7: UInt16 = UInt16(kVK_F7)
    public static let F8: UInt16 = UInt16(kVK_F8)
    public static let F9: UInt16 = UInt16(kVK_F9)
    public static let F10: UInt16 = UInt16(kVK_F10)
    public static let F11: UInt16 = UInt16(kVK_F11)
    public static let F12: UInt16 = UInt16(kVK_F12)
    public static let F13: UInt16 = UInt16(kVK_F13)
    public static let F14: UInt16 = UInt16(kVK_F14)
    public static let F15: UInt16 = UInt16(kVK_F15)
    public static let F16: UInt16 = UInt16(kVK_F16)
    public static let F17: UInt16 = UInt16(kVK_F17)
    public static let F18: UInt16 = UInt16(kVK_F18)
    public static let F19: UInt16 = UInt16(kVK_F19)
    public static let F20: UInt16 = UInt16(kVK_F20)

    // MARK: -

    public static let names: [UInt16: String] = [
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

    public static func getName(key: UInt16, names: [UInt16: String]? = nil) -> String? {
        if let map: [UInt16: String] = names ?? self.names where map.keys.contains(key) {
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

        guard let status: OSStatus = UCKeyTranslate(layoutPointer, key, UInt16(kUCKeyActionDown), modifierKeys, keyboardType, UInt32(kUCKeyTranslateNoDeadKeysMask), &deadKeys, maxStringLength, &stringLength, &stringBuffer) where status == Darwin.noErr else {
            return nil
        }

        return String(utf16CodeUnits: stringBuffer, count: stringLength).uppercaseString
    }
}