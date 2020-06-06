import AppKit
import Foundation
import Carbon

/// NSButton-based control for recording shortcut hotkeys. Unlike regular button, it will send actions
/// when the associated hotkey gets modified as the result of the user input.
open class ShortcutRecorderButton: NSButton, ShortcutRecorder {
    override public init(frame frameRect: NSRect) { super.init(frame: frameRect); self._init() }
    public required init?(coder: NSCoder) { super.init(coder: coder); self._init() }

    private func _init() {
        self.update()
    }

    /// Shortcut and window notification observer.
    private let observer: NotificationObserver = NotificationObserver(active: true)

    open var shortcut: Shortcut? {
        willSet {
            if newValue == self.shortcut { return }
            NotificationCenter.default.post(name: Self.shortcutWillChangeNotification, object: self)
        }
        didSet {
            if self.shortcut == oldValue { return }
            // Update shortcut hotkey change observation.
            if let shortcut = oldValue { self.observer.remove(observee: shortcut) }
            if let shortcut = self.shortcut { self.observer.add(name: Shortcut.hotkeyDidChangeNotification, observee: shortcut, handler: { [weak self] in self?.update() }) }
            // Should cancel recording if the hotkey gets set during active recording.
            if self.isRecording != false { self.isRecording = false } else { self.update() }
            NotificationCenter.default.post(name: Self.shortcutDidChangeNotification, object: self)
        }
    }

    /// Stores temporary modifier while hotkey is being recorded.
    private var modifier: KeyboardModifier? {
        didSet {
            if self.modifier == oldValue { return }
            self.update()
        }
    }

    open var isRecording: Bool = false {
        didSet {
            if self.isRecording == oldValue { return }
            if self.isRecording { self.makeFirstResponder() } else { self.restoreFirstResponder() }
            if self.modifier != nil { self.modifier = nil } else { self.update() }
            // Let the shortcut center know that current recorder has changed.
            if self.isRecording {
                ShortcutCenter.default.recorder = self
            } else if ShortcutCenter.default.recorder === self {
                ShortcutCenter.default.recorder = nil
            }
        }
    }

    /// Temporarily stores the reference to original first responder during hotkey recording.
    private weak var originalFirstResponder: NSResponder?

    // Makes self as the the first responder and stores the original first responder reference for later restoration.
    private func makeFirstResponder() {
        // Check if another instance of `Self` is already the first responder and use it's value instead. 
        var currentFirstResponder: NSResponder? = self.window?.firstResponder
        if let recorder = currentFirstResponder as? Self, recorder.isRecording { currentFirstResponder = recorder.originalFirstResponder }
        if self.originalFirstResponder == nil { self.originalFirstResponder = currentFirstResponder }
        if currentFirstResponder !== self { self.window?.makeFirstResponder(self) }
    }

    // Restores the original first responder if self is the current first responder and clears the original first responder reference.
    private func restoreFirstResponder() {
        let currentFirstResponder: NSResponder? = self.window?.firstResponder
        if currentFirstResponder === self && currentFirstResponder !== self.originalFirstResponder { self.window?.makeFirstResponder(self.originalFirstResponder) }
        self.originalFirstResponder = nil
    }

    /// Updates the button's title and appearance.
    private func update() {
        // ✊ Even when the title is empty, we still need a valid paragraph style.
        let style: NSMutableParagraphStyle = self.attributedTitle.attribute(NSAttributedString.Key.paragraphStyle, at: 0, effectiveRange: nil) as! NSMutableParagraphStyle? ?? NSMutableParagraphStyle(alignment: self.alignment)
        let modifier = self.modifier == nil || self.modifier == [] ? nil : self.modifier
        let hotkey = self.shortcut?.hotkey
        let color: NSColor
        let title: String

        if self.shortcut == nil {
            title = "INVALID"
            color = NSColor.red
        } else if self.isRecording {
            title = modifier.map({ self.title(forModifier: $0) }) ?? hotkey.map({ self.title(forHotkey: $0) }) ?? "Record shortcut"
            color = self.modifier == nil ? NSColor.tertiaryLabelColor : NSColor.secondaryLabelColor
        } else {
            title = hotkey.map({ self.title(forHotkey: $0) }) ?? "Click to record shortcut"
            color = NSColor.labelColor
        }

        if title == "" { NSLog("\(self) attempted to set empty title, this shouldn't be happening…") }
        self.attributedTitle = NSAttributedString(string: title, attributes: [.foregroundColor: color, .paragraphStyle: style, .font: self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)])
    }

    /// Returns the receiver's title for the keyboard modifier.
    open func title(forModifier modifier: KeyboardModifier) -> String {
        String(describing: modifier)
    }

    /// Returns the receiver's title for the keyboard key. 
    open func title(forKey key: KeyboardKey) -> String {
        String(describing: key)
    }

    /// Returns the receiver's title for the keyboard hotkey.
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
        if (self.isRecording || self.window?.firstResponder === self) && self.modifier == nil && self.shortcut != nil && KeyboardKey(event) == KeyboardKey.delete {
            self.shortcut?.hotkey = nil
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
            let shortcut: Shortcut? = self.shortcut
            if ShortcutCenter.default.shortcuts.contains(where: { $0 !== shortcut && $0.hotkey == hotkey }) {
                NSSound.beep()
            } else {
                self.shortcut?.hotkey = hotkey
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
            self.observer.remove(observee: oldWindow)
        }
        if let newWindow: NSWindow = newWindow {
            self.observer.add(name: NSWindow.didResignKeyNotification, observee: newWindow, handler: { [weak self] in self?.isRecording = false })
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
