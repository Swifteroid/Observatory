import Foundation

/*
Handler definition provides a way of storing and managing individual notification handlers, most properties
represent arguments passed into `NSNotificationCenter.addObserverForName` method.
*/
public protocol ObserverHandlerDefinitionProtocol
{
    var active: Bool { get }
}

// MARK: -

public class ObserverHandlerDefinition
{

    public typealias Block = () -> ()

    /*
    Convention block represents an Objective-C compatible closure, which is stored as reference – the main reason
    to have it is it's ability to be compared against other blocks. This is useful when we want to be able to remove
    handlers observer by handler as well as other parameters.
    */
    public typealias ConventionBlock = @convention(block) () -> ()

}