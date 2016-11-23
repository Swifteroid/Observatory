import Foundation

open class Observer
{
    /* 
    Specifies whether the observer is active or not.
    */
    open var active: Bool = false {
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

    open class func compareBlocks(_ lhs: Any, _ rhs: Any) -> Bool {
        if (lhs is ObserverConventionHandler && rhs is ObserverConventionHandler) {
            return unsafeBitCast(lhs as! ObserverConventionHandler, to: AnyObject.self) === unsafeBitCast(rhs as! ObserverConventionHandler, to: AnyObject.self)
        } else {
            return false
        }
    }
}

extension Observer
{
    public enum Error: Swift.Error
    {
        /*
        Observer doesn't recognise provided handler signature. 
        */
        case unrecognisedHandlerSignature
    }
}