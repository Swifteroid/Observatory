import Foundation

public class Observer
{
    /* 
    Specifies whether the observer is active or not.
    */
    public var active: Bool = false {
        didSet {
            if self.active == oldValue {
                return
            } else if self.active {
                self.activate()
            } else {
                self.deactivate()
            }
        }
    }

    internal func activate() {
        // …
    }

    internal func deactivate() {
        // …
    }

    // MARK: -

    public init() {
    }

    public convenience init(active: Bool) {
        self.init()

        // Otherwise `didSet` won't get invoked.

        ({ self.active = active })()
    }

    // MARK: -

    public class func compareBlocks(lhs: Any, _ rhs: Any) -> Bool {
        if (lhs is ObserverConventionHandler && rhs is ObserverConventionHandler) {
            return unsafeBitCast(lhs as! ObserverConventionHandler, AnyObject.self) === unsafeBitCast(rhs as! ObserverConventionHandler, AnyObject.self)
        } else {
            return false
        }
    }
}

// MARK: -

extension Observer
{
    public class func weakenHandler<T:AnyObject>(instance: T, method: (T) -> ObserverHandler) -> ObserverHandler {
        return BlockUtility.weaken(instance, method: method)
    }
}

extension Observer
{
    public enum Error: ErrorType
    {
        /*
        Observer doesn't recognise provided handler signature. 
        */
        case UnrecognisedHandlerSignature
    }
}

/*
Provides an easy access to handler weakening methods within the class.
*/
public protocol ObserverHandlerProtocol: class
{
    func weakenHandler(method: (Self) -> ObserverHandler) -> ObserverHandler
}

extension ObserverHandlerProtocol
{
    public func weakenHandler(method: (Self) -> ObserverHandler) -> ObserverHandler {
        return Observer.weakenHandler(self, method: method)
    }
}