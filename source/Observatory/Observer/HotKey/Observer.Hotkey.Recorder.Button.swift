import AppKit
import Foundation
import Carbon

/// NSButton-based control for recording and managing hotkeys. Unlike regular button, it will send actions
/// when the associated hotkey gets modified as the result of user input.
open class HotkeyRecorderButton: NSButton, HotkeyRecorder {
    private lazy var windowNotificationObserver: NotificationObserver = NotificationObserver(active: true)

    open var hotkey: KeyboardHotkey? {
        willSet {
            if newValue == self.hotkey { return }
            NotificationCenter.default.post(name: Self.hotkeyWillChangeNotification, object: self)
        }
        didSet {
            if self.hotkey == oldValue { return }
            // Should cancel recording if the hotkey gets set during active recording.
            self.register()
            if self.isRecording != false { self.isRecording = false } else { self.update() }
            NotificationCenter.default.post(name: Self.hotkeyDidChangeNotification, object: self)
        }
    }

    open var command: HotkeyCommand? {
        didSet {
            if self.command == oldValue { return }
            self.register()
            self.update()
        }
    }

    /// Successfully registered hotkey-command tuple.
    private var registration: (hotkey: KeyboardHotkey, command: HotkeyCommand)?

    /// Attempts to update registration to the current command and hotkey.
    private func register() {
        let oldHotkey: KeyboardHotkey? = self.registration?.hotkey
        let newHotkey: KeyboardHotkey? = self.hotkey
        let oldCommand: HotkeyCommand? = self.registration?.command
        let newCommand: HotkeyCommand? = self.command
        if newHotkey == oldHotkey && newCommand == oldCommand { return }

        if let oldHotkey: KeyboardHotkey = oldHotkey, HotkeyCenter.default.commands[oldHotkey] == self.command {
            HotkeyCenter.default.remove(hotkey: oldHotkey)
        }

        // Todo: It would be good to return some status, but because definitions might not fail immediately this is a non-trivial job. Leaving it
        // todo: as a reminder in case this ever proves to be a problem…
        if let newHotkey: KeyboardHotkey = newHotkey, let newCommand: HotkeyCommand = newCommand {
            HotkeyCenter.default.add(hotkey: newHotkey, command: newCommand)
            self.registration = (newHotkey, newCommand)
        } else {
            self.registration = nil
        }
    }

    open var isRecording: Bool = false {
        didSet {
            if self.isRecording == oldValue { return }
            if self.isRecording { self.makeFirstResponder() } else { self.restoreFirstResponder() }
            if self.modifier != nil { self.modifier = nil } else { self.update() }
            // Let hotkey center know that current recorder changed.
            if self.isRecording {
                HotkeyCenter.default.recorder = self
            } else if HotkeyCenter.default.recorder === self {
                HotkeyCenter.default.recorder = nil
            }
        }
    }

    /// Stores temporary modifier while hotkey is being recorded.
    private var modifier: KeyboardModifier? {
        didSet {
            if self.modifier == oldValue { return }
            self.update()
        }
    }

    /// Temporarily stores the reference to original first responder during hotkey recording.
    private weak var originalFirstResponder: NSResponder?

    // Makes self as the the first responder and stores the original first responder reference for later restoration.
    private func makeFirstResponder() {
        // Self might already be the first responder,
        let currentFirstResponder: NSResponder? = self.window?.firstResponder
        if self.originalFirstResponder == nil { self.originalFirstResponder = currentFirstResponder }
        if currentFirstResponder !== self { self.window?.makeFirstResponder(self) }
    }

    // Restores the original first responder if self is the current first responder and clears the original first responder reference.
    private func restoreFirstResponder() {
        let currentFirstResponder: NSResponder? = self.window?.firstResponder
        if currentFirstResponder === self && currentFirstResponder !== self.originalFirstResponder { self.window?.makeFirstResponder(self.originalFirstResponder) }
        self.originalFirstResponder = nil
    }

    private func update() {
        // In case if title is empty, we still need a valid paragraph style…
        let style: NSMutableParagraphStyle = self.attributedTitle.attribute(NSAttributedString.Key.paragraphStyle, at: 0, effectiveRange: nil) as! NSMutableParagraphStyle? ?? NSMutableParagraphStyle(alignment: self.alignment)
        let colour: NSColor
        let title: String

        if self.isRecording {
            // Make sure the receiver is the first responder.
            self.makeFirstResponder()
            if let modifier: KeyboardModifier = self.modifier, modifier != [] {
                title = self.title(forModifier: modifier)
            } else if let hotkey: KeyboardHotkey = self.hotkey {
                title = self.title(forHotkey: hotkey)
            } else {
                title = "Record hotkey"
            }
            colour = self.modifier == nil ? NSColor.tertiaryLabelColor : NSColor.secondaryLabelColor
        } else {
            if let hotkey: KeyboardHotkey = self.hotkey {
                // Hotkey and command are set and registered the button will appear normal. If hotkey is set but command is not the button
                // will appear grayed out. If hotkey and command are set but not registered the button will have a warning.
                if self.registration != nil || self.command == nil {
                    title = self.title(forHotkey: hotkey)
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
            self.attributedTitle = NSAttributedString(string: title, attributes: [.foregroundColor: colour, .paragraphStyle: style, .font: self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)])
        }
    }

    open func title(forModifier modifier: KeyboardModifier) -> String {
        String(describing: modifier)
    }

    open func title(forKey key: KeyboardKey) -> String {
        String(describing: key)
    }

    open func title(forHotkey hotkey: KeyboardHotkey) -> String {
        "\(self.title(forModifier: hotkey.modifier))\(self.title(forKey: hotkey.key))"
    }

    override open func resignFirstResponder() -> Bool {
        self.isRecording = false
        return super.resignFirstResponder()
    }

    override open var acceptsFirstResponder: Bool {
        self.isEnabled
    }

    override open func mouseDown(with event: NSEvent) {
        // Don't invoke super to avoid action sending.
        // super.mouseDown(with: event)
        self.isRecording = true
    }

    /// Handles hotkey recording and returns true when any custom logic was invoked.
    override open func performKeyEquivalent(with event: NSEvent) -> Bool {
        if !self.isEnabled { return false }

        // Pressing delete key without any modifiers clears current shortcut.
        if (self.isRecording || self.window?.firstResponder === self) && self.modifier == nil && self.hotkey != nil && KeyboardKey(event) == KeyboardKey.delete {
            self.hotkey = nil
            self.isRecording = false
            NotificationCenter.default.post(name: Self.hotkeyDidRecordNotification, object: self)
            let _ = self.sendAction(self.action, to: self.target)
            return true
        }

        // Pressing escape without modifiers during recording cancels it, pressing space while not recording starts it.
        if self.isRecording && (self.modifier == nil && KeyboardKey(event) == KeyboardKey.escape || self.isKeyEquivalent(event)) {
            self.isRecording = false
            return true
        } else if !self.isRecording && (self.window?.firstResponder === self && self.modifier == nil && KeyboardKey(event) == KeyboardKey.space || self.isKeyEquivalent(event)) {
            self.isRecording = true
            return true
        }

        // If not recording, there's nothing else to do…
        if !self.isRecording {
            return super.performKeyEquivalent(with: event)
        }

        // Pressing any key without modifiers is not a valid shortcut.
        if let modifier: KeyboardModifier = self.modifier {
            let hotkey: KeyboardHotkey = KeyboardHotkey(key: KeyboardKey(event), modifier: modifier)
            if HotkeyCenter.default.commands.keys.contains(hotkey) && HotkeyCenter.default.commands[hotkey] != self.command {
                NSSound.beep()
            } else {
                self.hotkey = hotkey
                self.isRecording = false
                NotificationCenter.default.post(name: Self.hotkeyDidRecordNotification, object: self)
                let _ = self.sendAction(self.action, to: self.target)
            }
        } else {
            NSSound.beep()
        }

        return true
    }

    /// You must invoke super when overriding this method.
    override open func flagsChanged(with event: NSEvent) {
        if self.isRecording {
            let modifier: KeyboardModifier = KeyboardModifier(event).intersection([.commandKey, .controlKey, .optionKey, .shiftKey])
            self.modifier = modifier == [] ? nil : modifier
        }
        super.flagsChanged(with: event)
    }

    /// You must invoke super when overriding this method.
    override open func viewWillMove(toWindow newWindow: NSWindow?) {
        if let oldWindow: NSWindow = self.window {
            self.windowNotificationObserver.remove(observee: oldWindow)
        }
        if let newWindow: NSWindow = newWindow {
            self.windowNotificationObserver.add(name: NSWindow.didResignKeyNotification, observee: newWindow, handler: { [weak self] in self?.isRecording = false })
        }
    }
}

extension NSMutableParagraphStyle {
    fileprivate convenience init(alignment: NSTextAlignment) {
        self.init()
        self.alignment = alignment
    }
}

extension NSButton {
    /// Checks if the event matches the button's key equivalent configuration.
    public func isKeyEquivalent(_ event: NSEvent) -> Bool {
        // 1. NSButton stores key equivalent string either in upper or lower case depending on whether Shift key
        //    was pressed or not. At the same time the modifier is doesn't include Shift.
        // 2. NSEvent characters are returned in lower case when Shift key is pressed WITH other modifiers. Using
        //    characters ignoring modifiers returns the string in correct case.

        //    Todo: This still might need better testing with other modifiers, like CapsLock.
        event.charactersIgnoringModifiers == self.keyEquivalent && KeyboardModifier(event.modifierFlags) == KeyboardModifier(self.keyEquivalent, self.keyEquivalentModifierMask)
    }
}

extension KeyboardModifier {
    /// Creates new keyboard modifier from the key equivalent string and modifier flags. If the key equivalent is an uppercase string
    /// the shift modifier flag will be included into the modifier flags.
    fileprivate init(_ keyEquivalent: String, _ flags: NSEvent.ModifierFlags) {
        let isUppercase = keyEquivalent.allSatisfy({ $0.isUppercase })
        self.init(isUppercase ? flags.union(.shift) : flags)
    }
}
