import Foundation

public class Observer
{
    public typealias Block = () -> ()

    /*
    Convention block represents an Objective-C compatible closure, which is stored as reference – the main reason
    to have it is it's ability to be compared against other blocks. This is useful when we want to be able to remove
    handlers observer by handler as well as other parameters.
    */
    public typealias ConventionBlock = @convention(block) () -> ()

    /* 
    Specifies whether the observer is active or not.
    */
    public var active: Bool = false

    // MARK: -

    public init() {
    }

    // MARK: -

    public class func compareBlocks(lhs: Any, _ rhs: Any) -> Bool {
        if (lhs is ConventionBlock && rhs is ConventionBlock) {
            return unsafeBitCast(lhs as! ConventionBlock, AnyObject.self) === unsafeBitCast(rhs as! ConventionBlock, AnyObject.self)
        } else {
            return false
        }
    }
}

// MARK: -

extension Observer
{
    public class func weakenHandler<T:AnyObject>(instance: T, method: (T) -> Block) -> Block {
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
public protocol ObserverHandler: class
{
    func weakenHandler(method: (Self) -> Observer.Block) -> Observer.Block
}

extension ObserverHandler
{
    public func weakenHandler(method: (Self) -> Observer.Block) -> Observer.Block {
        return Observer.weakenHandler(self, method: method)
    }
}