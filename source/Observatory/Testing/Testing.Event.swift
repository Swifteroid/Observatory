import Carbon

internal class Event {
    internal static func postMouseEvent(type: CGEventType, position: CGPoint? = nil, tap: CGEventTapLocation? = nil) {
        let event: CGEvent = CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: position ?? CGPoint(x: -10000, y: -10000), mouseButton: CGMouseButton.center)!
        event.post(tap: tap ?? CGEventTapLocation.cghidEventTap)
        self.wait()
    }

    private static func wait() {
        RunCurrentEventLoop(1 / 1000)
    }
}
