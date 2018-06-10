import Foundation

public protocol HotkeyRecorder: class
{

    /// Recorder state.
    var recording: Bool { get set }

    /// Current hotkey.
    var hotkey: KeyboardHotkey? { get set }

    /// Hotkey command identifier.
    var command: String? { get set }
}

extension HotkeyRecorder
{
    public static var hotkeyWillChangeNotification: Notification.Name { return Notification.Name("HotkeyRecorderHotkeyWillChangeNotification") }
    public static var hotkeyDidChangeNotification: Notification.Name { return Notification.Name("HotkeyRecorderHotkeyDidChangeNotification") }
    public static var hotkeyDidRecordNotification: Notification.Name { return Notification.Name("HotkeyRecorderHotkeyDidRecordNotification") }
}