import AppKit
import Foundation
import Carbon

open class HotkeyRecorderButton: NSButton, HotkeyRecorder
{

    // MARK: intercom

    private lazy var windowNotificationObserver: NotificationObserver = NotificationObserver(active: true)

    // MARK: -

    open var hotkey: KeyboardHotkey? {
        willSet {
            if self.hotkey == newValue { return }
            NotificationCenter.default.post(name: Notification.HotkeyWillChange, object: self)
        }
        didSet {
            if self.hotkey == oldValue { return }

            // Should cancel recording if we're setting hotkey while recording.

            self.register()
            self.recording = false
            self.needsDisplay = true

            NotificationCenter.default.post(name: Notification.HotkeyDidChange, object: self)
        }
    }

    @IBInspectable open var command: String? {
        didSet {
            if self.command == oldValue { return }

            self.register()
            self.needsDisplay = true
        }
    }

    // MARK: -

    /// Successfully registered hotkey-command tuple.

    private var registration: (hotkey: KeyboardHotkey, command: String)?

    /// Attempts to update registration to current command and hotkey. 

    private func register() {
        let oldHotkey: KeyboardHotkey? = self.registration?.hotkey
        let newHotkey: KeyboardHotkey? = self.hotkey
        let oldCommand: String? = self.registration?.command
        let newCommand: String? = self.command

        if newHotkey == oldHotkey && newCommand == oldCommand {
            return
        }

        if let oldHotkey: KeyboardHotkey = oldHotkey, HotkeyCenter.default.commands[oldHotkey] == self.command {
            try! HotkeyCenter.default.remove(hotkey: oldHotkey)
        }

        if let newHotkey: KeyboardHotkey = newHotkey, let newCommand: String = newCommand {
            do {
                try HotkeyCenter.default.add(hotkey: newHotkey, command: newCommand)
                self.registration = (newHotkey, newCommand)
            } catch {
                self.registration = nil
            }
        }
    }

    // MARK: -

    open var recording: Bool = false {
        didSet {
            if self.recording == oldValue { return }

            self.modifier = nil
            self.needsDisplay = true

            // Let hotkey center know that current recorder changed.

            if self.recording {
                HotkeyCenter.default.recorder = self
            } else if HotkeyCenter.default.recorder === self {
                HotkeyCenter.default.recorder = nil
            }
        }
    }

    // MARK: -

    /// Stores temporary modifier while hotkey is being recorded.

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

        // In case if title is empty, we still need a valid paragraph style…

        let style: NSMutableParagraphStyle = self.attributedTitle.attribute(NSAttributedStringKey.paragraphStyle, at: 0, effectiveRange: nil) as! NSMutableParagraphStyle? ?? NSMutableParagraphStyle(alignment: self.alignment)
        let colour: NSColor
        let title: String

        if self.recording {
            self.window!.makeFirstResponder(self)

            if let modifier: KeyboardModifier = self.modifier, modifier != [] {
                title = String(describing: modifier)
            } else if let hotkey: KeyboardHotkey = self.hotkey {
                title = String(describing: hotkey)
            } else {
                title = "Record hotkey"
            }

            colour = self.modifier == nil ? NSColor.tertiaryLabelColor : NSColor.secondaryLabelColor
        } else {
            if let hotkey: KeyboardHotkey = self.hotkey {

                // Hotkey and command are set and registered the button will appear normal. If hotkey is set but command is not the button
                // will appear grayed out. If hotkey and command are set but not registered the button will have a warning.

                if self.registration != nil || self.command == nil {
                    title = String(describing: hotkey)
                    colour = self.command == nil ? NSColor.secondaryLabelColor : NSColor.labelColor
                } else {

                    // Todo: this is all fancy shmancy, but we need a proper solution here…

                    title = "☠️"
                    colour = NSColor.secondaryLabelColor
                }
            } else {
                title = "Click to record hotkey"
                colour = NSColor.labelColor
            }
        }

        if title == "" {
            NSLog("\(self) attempted to set empty title, this shouldn't be happening…")
        } else {
            self.attributedTitle = NSAttributedString(string: title, attributes: [NSAttributedStringKey.foregroundColor: colour, NSAttributedStringKey.paragraphStyle: style])
        }
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

    /// Handles hotkey recording and returns true when any custom logic was invoked.

    override open func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard self.isEnabled else {
            return false
        }

        // Pressing delete key without any modifiers clears current shortcut.

        if CGKeyCode(event.keyCode) == KeyboardKey.delete && self.modifier == nil && self.hotkey != nil {
            self.hotkey = nil
            self.recording = false
            NotificationCenter.default.post(name: Notification.HotkeyDidRecord, object: self)
            return true
        }

        // Pressing escape without modifiers during recording cancels it, pressing space while not recording starts it.

        if self.recording && CGKeyCode(event.keyCode) == KeyboardKey.escape && self.modifier == nil {
            self.recording = false
            return true
        } else if !self.recording && CGKeyCode(event.keyCode) == KeyboardKey.space {
            self.recording = true
            return true
        }

        // If not recording, there's nothing else to do…

        if !self.recording {
            return super.performKeyEquivalent(with: event)
        }

        // Pressing any key without modifiers is not a valid shortcut.

        if let modifier: KeyboardModifier = self.modifier {
            let hotkey: KeyboardHotkey = KeyboardHotkey(key: event.keyCode, modifier: modifier)

            if HotkeyCenter.default.commands.keys.contains(hotkey) && HotkeyCenter.default.commands[hotkey] != self.command {
                NSSound.beep()
            } else {
                self.hotkey = hotkey
                self.recording = false
                NotificationCenter.default.post(name: Notification.HotkeyDidRecord, object: self)
            }
        } else {
            NSSound.beep()
        }

        return true
    }

    private func handleWindowDidResignKeyNotification() {
        self.recording = false
    }

    override open func flagsChanged(with event: NSEvent) {
        if self.recording {
            let modifier: KeyboardModifier = KeyboardModifier(flags: event.modifierFlags).intersection([.commandKey, .controlKey, .optionKey, .shiftKey])
            self.modifier = modifier == [] ? nil : modifier
        }

        super.flagsChanged(with: event)
    }

    // MARK: -

    override open func viewWillMove(toWindow newWindow: NSWindow?) {
        if let oldWindow: NSWindow = self.window {
            self.windowNotificationObserver.remove(observee: oldWindow)
        }

        if let newWindow: NSWindow = newWindow {
            self.windowNotificationObserver.add(name: NSWindow.didResignKeyNotification, observee: newWindow, handler: { [weak self] in self?.handleWindowDidResignKeyNotification() })
        }
    }
}

// MARK: -

extension HotkeyRecorderButton
{
    public struct Notification
    {
        public static let HotkeyWillChange: Foundation.Notification.Name = Foundation.Notification.Name(rawValue: "HotkeyRecorderButtonHotkeyWillChangeNotification")
        public static let HotkeyDidChange: Foundation.Notification.Name = Foundation.Notification.Name(rawValue: "HotkeyRecorderButtonHotkeyDidChangeNotification")
        public static let HotkeyDidRecord: Foundation.Notification.Name = Foundation.Notification.Name(rawValue: "HotkeyRecorderButtonHotkeyDidRecordNotification")
    }
}

extension NSMutableParagraphStyle
{
    fileprivate convenience init(alignment: NSTextAlignment) {
        self.init()
        self.alignment = alignment
    }
}