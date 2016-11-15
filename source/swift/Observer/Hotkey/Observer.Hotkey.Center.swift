import Foundation

public class HotkeyCenter
{
    public static let instance: HotkeyCenter = HotkeyCenter()

    // MARK: -

    public var recorder: HotkeyRecorderProtocol? = nil {
        didSet {
            if self.recorder === oldValue { return }
            self.update()
        }
    }

    public var hotkeys: [KeyboardHotkey: String!] = [:]

    private var weakObservers: [Weak] = [] {
        didSet {
            self.update()
        }
    }

    private var observers: [HotkeyObserver] {
        get { return weakObservers.reduce([], combine: { $1.value == nil ? $0 : $0 + [$1.value as! HotkeyObserver] }) }
        set { self.weakObservers = newValue.map({ Weak(value: $0) }) }
    }

    public func register(observer: HotkeyObserver) -> Self {
        self.observers.append(observer)
        return self
    }

    public func unregister(observer: HotkeyObserver) -> Self {
        self.observers = self.observers.filter({ $0 !== observer })
        return self
    }

    public func update() {
        for observer in self.observers {
            for definition in observer.definitions {
                definition.ignored = self.recorder != nil
            }
        }
    }
}