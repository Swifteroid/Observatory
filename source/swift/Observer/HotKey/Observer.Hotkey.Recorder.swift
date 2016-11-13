import AppKit
import Foundation
import Carbon

public class HotkeyRecorderButton: NSButton
{

    // MARK: intercom

    private lazy var windowNotificationObserver: NotificationObserver = NotificationObserver(active: true)

    // MARK: -

    public private(set) var hotkey: KeyboardHotkey? {
        didSet {
            if self.hotkey == oldValue { return }
            self.needsDisplay = true
            NSNotificationCenter.defaultCenter().postNotificationName(Notification.HotkeyDidChange, object: self)
        }
    }

    private var modifier: KeyboardModifier? {
        didSet {
            if self.modifier == oldValue { return }
            self.needsDisplay = true
        }
    }

    public var recording: Bool = false {
        didSet {
            if self.recording == oldValue { return }
            self.needsDisplay = true
        }
    }

    // MARK: -

    override public func viewWillDraw() {
        super.viewWillDraw()
        self.update()
    }

    private func update() {
        let style: NSMutableParagraphStyle = self.attributedTitle.attribute(NSParagraphStyleAttributeName, atIndex: 0, effectiveRange: nil) as! NSMutableParagraphStyle
        let colour: NSColor = self.recording ? (self.modifier == nil ? NSColor.tertiaryLabelColor() : NSColor.secondaryLabelColor()) : NSColor.labelColor()
        let title: String

        if self.recording {
            self.window!.makeFirstResponder(self)

            if let modifier: KeyboardModifier = self.modifier {
                title = self.modifierToString(modifier)
            } else if let hotkey: KeyboardHotkey = self.hotkey {
                title = self.hotkeyToString(hotkey)
            } else {
                title = "Record hotkey"
            }
        } else {
            if let hotkey: KeyboardHotkey = self.hotkey {
                title = self.hotkeyToString(hotkey)
            } else {
                title = "Click to record hotkey"
            }
        }

        self.attributedTitle = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: colour, NSParagraphStyleAttributeName: style])
    }

    // MARK: -

    public func modifierToString(modifier: KeyboardModifier) -> String {
        var string: String = ""

        if modifier.contains(KeyboardModifier.AlphaLock) { string += "⇪" }
        if modifier.contains(KeyboardModifier.CommandKey) { string += "⌘" }
        if modifier.contains(KeyboardModifier.ControlKey) { string += "⌃" }
        if modifier.contains(KeyboardModifier.OptionKey) { string += "⌥" }
        if modifier.contains(KeyboardModifier.ShiftKey) { string += "⇧" }

        return string
    }

    public func hotkeyToString(hotkey: KeyboardHotkey) -> String {
        return "\(self.modifierToString(KeyboardModifier(rawValue: hotkey.modifier)))\(KeyboardKey.getName(hotkey.key) ?? "")"
    }

    // MARK: -

    override public func resignFirstResponder() -> Bool {
        self.recording = false
        return super.resignFirstResponder()
    }

    override public var acceptsFirstResponder: Bool {
        return self.enabled
    }

    override public func mouseDown(event: NSEvent) {
        super.mouseDown(event)
        self.recording = true
    }

    override public func keyDown(event: NSEvent) {
        if !self.performKeyEquivalent(event) {
            super.keyDown(event)
        }
    }

    override public func performKeyEquivalent(event: NSEvent) -> Bool {
        guard self.enabled else {
            return false
        }

        if event.keyCode == UInt16(KeyboardKey.Delete) && self.modifier == nil && self.hotkey != nil {
            self.recording = false
            self.hotkey = nil
            return true
        }

        if self.recording && event.keyCode == UInt16(KeyboardKey.Escape) && self.modifier == nil {
            self.recording = false
            return true
        } else if self.recording && self.modifier == nil {
            NSBeep()
            return true
        } else if self.recording {
            self.hotkey = KeyboardHotkey(key: UInt32(event.keyCode), modifier: self.modifier!)
            self.recording = false
            return true
        }

        if !self.recording && event.keyCode == UInt16(KeyboardKey.Space) {
            self.recording = true
            return true
        }

        return super.performKeyEquivalent(event)
    }

    override public func flagsChanged(event: NSEvent) {
        self.modifier = KeyboardModifier(flags: event.modifierFlags)
        super.flagsChanged(event)
    }

    // MARK: -

    override public func viewWillMoveToWindow(newWindow: NSWindow?) {
        if let oldWindow: NSWindow = self.window {
            self.windowNotificationObserver.remove(oldWindow)
        }

        if let newWindow: NSWindow = newWindow {
            try! self.windowNotificationObserver.add(NSWindowDidBecomeKeyNotification, observable: newWindow, handler: { [unowned self] in self.recording = false })
        }
    }
}

// MARK: -

extension HotkeyRecorderButton
{
    public struct Notification
    {
        public static let HotkeyDidChange: String = "HotkeyRecorderButtonHotkeyDidChangeNotification"
    }
}