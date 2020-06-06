import Foundation

public protocol ShortcutRecorder: class {

    /// Specifies whether recorder is currently recording or not.
    var isRecording: Bool { get set }

    /// Current shortcut.
    var shortcut: Shortcut? { get set }
}

extension ShortcutRecorder {
    /// Posted prior `ShortcutRecorder`'s `shortcut` property gets changed, this gets posted, both, when the shortcut is changed
    /// by outside code and when the new hotkey gets recorded.
    public static var shortcutWillChangeNotification: Notification.Name { Notification.Name("\(ShortcutRecorder.self)ShortcutWillChangeNotification") }

    /// Posted after `ShortcutRecorder`'s `shortcut` value gets changed, this gets posted, both, when the shortcut is changed
    /// by outside code and when the new hotkey gets recorded.
    public static var shortcutDidChangeNotification: Notification.Name { Notification.Name("\(ShortcutRecorder.self)ShortcutDidChangeNotification") }

    /// Posted after `ShortcutRecorder`'s associated hotkey gets recorded and after `shortcutWillChange` and `shortcutDidChange`
    /// notifications. This is posted only when new hotkey gets recoded by the user.
    public static var hotkeyDidRecordNotification: Notification.Name { Notification.Name("\(ShortcutRecorder.self)HotkeyDidRecordNotification") }
}
