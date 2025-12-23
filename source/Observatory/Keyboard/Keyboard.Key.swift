import AppKit.NSEvent
import Carbon

/// Represents a physical keyboard key. Don't forget – there are different keyboard layouts for handling different languages.
public struct KeyboardKey: RawRepresentable {
    public init(rawValue: Int) { self.rawValue = rawValue }
    public init(_ rawValue: Int) { self.init(rawValue: rawValue) }
    public init(_ keyCode: CGKeyCode) { self.init(Int(keyCode)) }
    public init(_ event: NSEvent) { self.init(Int(event.keyCode)) }

    public init?(_ name: String) { self.init(name, custom: Self.names) }
    public init?(_ name: String, custom map: [KeyboardKey: String]) { self.init(name, layout: .ascii, custom: map) }
    public init?(_ name: String, layout: Layout, custom map: [KeyboardKey: String]? = nil) { self.init(name, layout: layout.data, custom: map) }

    /// Attempts to create a KeyboardKey from the corresponding name in the specified (or default, otherwise) keyboard layout.
    public init?(_ name: String, layout: Data?, custom map: [KeyboardKey: String]? = nil) {
        if name.isEmpty { return nil }
        // 😍 Oh this is priceless… Couldn't find an easy way to map a character into key code, but obviously this should be possible
        // by somehow digesting the keyboard layout data. A sillsdev/Ukelele might be a good source of inspiration along with
        // the CarbonCore/UnicodeUtilities.h. With some inspiration from browserstack/OSXVNC we can also just iterate through
        // all available key codes and compare the name, of which there should be only 127 (0x7F) tops based on the highest virtual
        // key code constant in HIToolbox/Events.h. This probably has some limitations, including performance, but should be a decent
        // solution for the most typical situations.
        let string = name.uppercased()
        for i in 0x00 ... 0x7F where KeyboardKey(i).name(layout: layout, custom: map)?.uppercased() == string {
            self.init(i)
            return
        }
        return nil
    }

    /// The virtual key code, CGKeyCode.
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

    /// Returns the key name in current ASCII layout if available, and if not, falls back to the current layout no matter whether ASCII or not.
    public var name: String? {
        self.name(custom: Self.names)
    }

    /// Returns the key name in current ASCII layout if available, and if not, falls back to the current layout no matter whether ASCII or not.
    public func name(custom map: [KeyboardKey: String]) -> String? {
        self.name(layout: .ascii, custom: map) ?? self.name(layout: .current, custom: map)
    }

    public func name(layout: Layout, custom map: [KeyboardKey: String]? = nil) -> String? {
        self.name(layout: layout.data, custom: map)
    }

    public func name(layout: Data?, custom map: [KeyboardKey: String]? = nil) -> String? {
        if let name = map?[self] { return name }
        guard let layout = layout ?? Layout.ascii.data else { return nil }

        let maxStringLength = 4 as Int
        var stringBuffer = [UniChar](repeating: 0, count: maxStringLength)
        var stringLength = 0 as Int

        let modifierKeys = 0 as UInt32
        var deadKeys = 0 as UInt32
        let keyboardType = UInt32(LMGetKbdType())

        guard let layout = layout.withUnsafeBytes({ $0.baseAddress?.assumingMemoryBound(to: UCKeyboardLayout.self) }) else { return nil }
        let status = UCKeyTranslate(layout, CGKeyCode(self.rawValue), CGKeyCode(kUCKeyActionDown), modifierKeys, keyboardType, UInt32(kUCKeyTranslateNoDeadKeysMask), &deadKeys, maxStringLength, &stringLength, &stringBuffer)
        guard status == Darwin.noErr else { return nil }

        return String(utf16CodeUnits: stringBuffer, count: stringLength).uppercased()
    }
}

extension KeyboardKey {
    /// Predefined name map for keys, mostly the ones that are language independent and not available via `UCKeyTranslate`.
    public static let names: [KeyboardKey: String] = [
        .keypadClear: "⌧",
        .keypadEnter: "⌅",

        .capsLock: "⇪",
        .command: "⌘",
        .control: "⌃", .rightControl: "⌃",
        .option: "⌥", .rightOption: "⌥",
        .shift: "⇧", .rightShift: "⇧",

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
        .space: "␣",
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
}

extension KeyboardKey: Equatable, Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(self.rawValue) }
}

extension KeyboardKey: CustomStringConvertible {
    public var description: String { self.name(custom: Self.names) ?? "Key Code: \(self.rawValue)" }
}

extension KeyboardKey {
    public enum Layout: CaseIterable {
        case ascii
        case current
    }
}

extension KeyboardKey.Layout {
    /// Needed for serializing access to Carbon's TIS keyboard layout APIs, which can crash under concurrent calls,
    /// ensuring layout data retrieval is thread-safe.
    private static let lock = NSLock()

    /// Cache layout data by input source – this minimizes calls to Carbon's TIS, which are super-unstable and thread-unsafe…
    fileprivate static var cache: [Self: Data] = [:]
    private static func invalidateCaches() { Self.lock.withLock({ Self.cache = [:] }) }

    /// Input source change observers.
    private static var observers: [NSObjectProtocol] = []
    private static func observe() -> [NSObjectProtocol] {
        // https://leopard-adc.pepas.com/documentation/TextFonts/Reference/TextInputSourcesReference/TextInputSourcesReference.pdf
        let notifications = [kTISNotifySelectedKeyboardInputSourceChanged, kTISNotifyEnabledKeyboardInputSourcesChanged].compactMap({ Notification.Name($0 as String) })
        return notifications.map({ DistributedNotificationCenter.default().addObserver(forName: $0, object: nil, queue: nil, using: { _ in Self.invalidateCaches() }) })
    }


    /// The unicode keyboard layout, with some great insight from:
    ///  - https://jongampark.wordpress.com/2015/07/17.
    ///  - https://github.com/cocoabits/MASShortcut/issues/60
    public var data: Data? {
        // We still want the locking, but not while waiting for the main-thread dispatch, as it can produce short-deadlocks.

        if let data = Self.lock.withLock({ Self.cache[self] }) { return data }
        Self.lock.withLock({ if Self.observers.isEmpty { Self.observers = Self.observe() } })
        var data: Data?

        do {
            data = try Thread.mainly(timeout: .milliseconds(50), {
                // 🧪 If testing outside the main thread, make sure to lock this, otherwise will cause a different crash…
                // Self.lock.withLock({})
                // ✊ What is interesting is that kTISPropertyUnicodeKeyLayoutData is still used when it queries last ASCII capable keyboard. It
                // is TISCopyCurrentASCIICapableKeyboardLayoutInputSource() not TISCopyCurrentASCIICapableKeyboardInputSource() to call. The latter
                // does not guarantee that it would return an keyboard input with a layout.
                let inputSource = switch self {
                    case .ascii: TISCopyCurrentASCIICapableKeyboardLayoutInputSource()?.takeRetainedValue()
                    case .current: TISCopyCurrentKeyboardInputSource()?.takeRetainedValue()
                }
                guard let inputSource else { return nil }
                guard let data = TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData) else { return nil }
                guard let data = Unmanaged<AnyObject>.fromOpaque(data).takeUnretainedValue() as? NSData, data.count > 0 else { return nil }
                // Hard-copy the data to avoid any external modifications.
                return Data(data as Data)
            })
        } catch {
            NSLog("Failed to retrieve keyboard layout data: TIS API couldn't be called on the main thread.")
        }

        if let data { Self.lock.withLock({ Self.cache[self] = data }) }
        return data
    }
}

extension Thread {
    fileprivate enum Error: Swift.Error { case timeout }
    @discardableResult fileprivate static func mainly<T>(timeout: DispatchTimeInterval, _ action: @escaping () -> T) throws -> T {
        if Thread.isMainThread { return action() }
        let semaphore = (dispatch: DispatchSemaphore(value: 0), work: DispatchSemaphore(value: 0))
        var result: T?
        var item: DispatchWorkItem?
        item = DispatchWorkItem {
            // If we timed out before the item even started, we cancel it and it should no-op.
            semaphore.dispatch.signal()
            defer { semaphore.work.signal() }
            if item?.isCancelled == false { result = action() }
        }
        // Only time out if the main queue couldn't begin running our block. But once started, wait for completion…
        if let item { DispatchQueue.main.async(execute: item) }
        if semaphore.dispatch.wait(timeout: .now() + timeout) == .timedOut { item?.cancel(); throw Error.timeout }
        semaphore.work.wait()
        if let result { return result } else { throw Error.timeout }
    }
}
