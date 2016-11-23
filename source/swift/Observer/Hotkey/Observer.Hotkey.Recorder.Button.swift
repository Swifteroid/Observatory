import AppKit
import Foundation
import Carbon

open class HotkeyRecorderButton: NSButton, HotkeyRecorderProtocol
{

    // MARK: intercom

    private lazy var windowNotificationObserver: NotificationObserver = NotificationObserver(active: true)

    // MARK: -

    open var hotkey: KeyboardHotkey? {
        willSet {
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.HotkeyWillChange), object: self)
        }
        didSet {
            if self.hotkey == oldValue { return }

            if let oldValue: KeyboardHotkey = oldValue, HotkeyCenter.instance.commands[oldValue] == self.command {
                HotkeyCenter.instance.commands.removeValue(forKey: oldValue)
            }

            if let newValue: KeyboardHotkey = self.hotkey {
                HotkeyCenter.instance.commands[newValue] = self.command
            }

            self.needsDisplay = true
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.HotkeyDidChange), object: self)
        }
    }

    @IBInspectable open var command: String!

    open var recording: Bool = false {
        didSet {
            if self.recording == oldValue { return }
            self.modifier = nil
            self.needsDisplay = true

            // Let hotkey center know that current recorder changed.

            if self.recording {
                HotkeyCenter.instance.recorder = self
            } else if HotkeyCenter.instance.recorder === self {
                HotkeyCenter.instance.recorder = nil
            }
        }
    }

    // MARK: -

    /*
    Stores temporary modifier while hotkey is being recorded.
    */
    private var modifier: KeyboardModifier? {
        didSet {
            if self.modifier == oldValue { return }
            self.needsDisplay = true
        }
    }

    // MARK: -

    override open func viewWillDraw() {
        super.viewWillDraw()
        self.update()
    }

    private func update() {
        let style: NSMutableParagraphStyle = self.attributedTitle.attribute(NSParagraphStyleAttributeName, at: 0, effectiveRange: nil) as! NSMutableParagraphStyle
        let colour: NSColor = self.recording ? (self.modifier == nil ? NSColor.tertiaryLabelColor : NSColor.secondaryLabelColor) : NSColor.labelColor
        let title: String

        if self.recording {
            self.window!.makeFirstResponder(self)

            if let modifier: KeyboardModifier = self.modifier {
                title = self.toString(modifier: modifier)
            } else if let hotkey: KeyboardHotkey = self.hotkey {
                title = self.toString(hotkey: hotkey)
            } else {
                title = "Record hotkey"
            }
        } else {
            if let hotkey: KeyboardHotkey = self.hotkey {
                title = self.toString(hotkey: hotkey)
            } else {
                title = "Click to record hotkey"
            }
        }

        self.attributedTitle = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: colour, NSParagraphStyleAttributeName: style])
    }

    // MARK: -

    open func toString(modifier: KeyboardModifier) -> String {
        var string: String = ""

        if modifier.contains(KeyboardModifier.CapsLock) { string += "⇪" }
        if modifier.contains(KeyboardModifier.CommandKey) { string += "⌘" }
        if modifier.contains(KeyboardModifier.ControlKey) { string += "⌃" }
        if modifier.contains(KeyboardModifier.OptionKey) { string += "⌥" }
        if modifier.contains(KeyboardModifier.ShiftKey) { string += "⇧" }

        return string
    }

    open func toString(hotkey: KeyboardHotkey) -> String {
        return "\(self.toString(modifier: KeyboardModifier(rawValue: hotkey.modifier)))\(KeyboardKey.getName(key: hotkey.key) ?? "")"
    }

    // MARK: -

    override open func resignFirstResponder() -> Bool {
        self.recording = false
        return super.resignFirstResponder()
    }

    override open var acceptsFirstResponder: Bool {
        return self.isEnabled
    }

    override open func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.recording = true
    }

    override open func keyDown(with event: NSEvent) {
        if !self.performKeyEquivalent(with: event) {
            super.keyDown(with: event)
        }
    }

    override open func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard self.isEnabled else {
            return false
        }

        if event.keyCode == UInt16(KeyboardKey.Delete) && self.modifier == nil && self.hotkey != nil {
            self.hotkey = nil
            self.recording = false
            return true
        }

        if self.recording && event.keyCode == UInt16(KeyboardKey.Escape) && self.modifier == nil {
            self.recording = false
            return true
        } else if self.recording && self.modifier == nil {
            NSBeep()
            return true
        } else if self.recording {
            let hotkey: KeyboardHotkey = KeyboardHotkey(key: event.keyCode, modifier: self.modifier!)

            if HotkeyCenter.instance.commands.keys.contains(hotkey) && HotkeyCenter.instance.commands[hotkey] != self.command {
                NSBeep()
            } else {
                self.hotkey = hotkey
                self.recording = false
            }

            return true
        }

        if !self.recording && event.keyCode == UInt16(KeyboardKey.Space) {
            self.recording = true
            return true
        }

        return super.performKeyEquivalent(with: event)
    }

    private func handleWindowDidResignKeyNotification() {
        self.recording = false
    }

    override open func flagsChanged(with event: NSEvent) {
        self.modifier = KeyboardModifier(flags: event.modifierFlags)
        super.flagsChanged(with: event)
    }

    // MARK: -

    override open func viewWillMove(toWindow newWindow: NSWindow?) {
        if let oldWindow: NSWindow = self.window {
            self.windowNotificationObserver.remove(observable: oldWindow)
        }

        if let newWindow: NSWindow = newWindow {
            try! self.windowNotificationObserver.add(name: AppKit.Notification.Name.NSWindowDidResignKey, observable: newWindow, handler: { [unowned self] in self.handleWindowDidResignKeyNotification() })
        }
    }
}

// MARK: -

extension HotkeyRecorderButton
{
    public struct Notification
    {
        public static let HotkeyWillChange: String = "HotkeyRecorderButtonHotkeyWillChangeNotification"
        public static let HotkeyDidChange: String = "HotkeyRecorderButtonHotkeyDidChangeNotification"
    }
}