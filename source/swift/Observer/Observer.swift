import Foundation

public class Observer
{
    /*
    Block is a very basic callback 
    */
    public typealias Block = () -> Void

    /*
    Convention block represents an Objective-C compatible closure, which is stored as reference – the main reason
    to have it is it's ability to be compared against other blocks.
    */
    public typealias ConventionBlock = @convention(block) () -> Void

    /* 
    Specifies whether the observer is active or not.
    */
    public var active: Bool = false

    public init() {
    }

    /*
    Compares two blocks for equality.
    */
    public class func compareBlocks(block1: Any, _ block2: Any) -> Bool {
        return block1 is ConventionBlock && block2 is ConventionBlock && unsafeBitCast(block1 as! ConventionBlock, AnyObject.self) === unsafeBitCast(block2 as! ConventionBlock, AnyObject.self)
    }
}

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
public protocol ObserverHandler: AnyObject
{
    func weakenHandler(method: (Self) -> Observer.Block) -> Observer.Block
}

extension ObserverHandler
{
    public func weakenHandler(method: (Self) -> Observer.Block) -> Observer.Block {
        return Observer.weakenHandler(self, method: method)
    }
}