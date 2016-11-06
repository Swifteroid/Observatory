import Foundation

/*
Handler definition provides a way of storing and managing individual notification handlers, most properties
represent arguments passed into `NSNotificationCenter.addObserverForName` method.
*/
protocol ObserverHandlerDefinitionProtocol
{
    var active: Bool { get }
}