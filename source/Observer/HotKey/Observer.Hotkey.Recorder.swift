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