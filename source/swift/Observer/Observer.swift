import Foundation

public protocol ObserverProtocol
{
    var active: Bool { get }
    var inactive: Bool { get }
}

extension ObserverProtocol
{
    public var inactive: Bool {
        return !self.active
    }
}

// MARK: -

open class Observer: ObserverProtocol
{
    /* 
    Specifies whether the observer is active or not.
    */
    open internal(set) var active: Bool = false

    // MARK: -

    public init() {
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