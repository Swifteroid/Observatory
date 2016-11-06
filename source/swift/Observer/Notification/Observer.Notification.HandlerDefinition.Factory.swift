import Foundation

public class NotificationObserverHandlerDefinitionFactory
{
    public var name: String
    public var observable: AnyObject?
    public var queue: NSOperationQueue?
    public var handler: Any

    // MARK: -

    public init(name: String, observable: AnyObject?, queue: NSOperationQueue?, handler: Any) {
        self.name = name
        self.observable = observable
        self.queue = queue
        self.handler = handler
    }

    // MARK: -

    public func construct() throws -> NotificationObserverHandlerDefinition {
        var definition: NotificationObserverHandlerDefinition!
        var handler: Any

        if self.handler is ObserverHandler {
            handler = { (notification: NSNotification) in (definition.handler.original as! ObserverHandler)() }
        } else if self.handler is ObserverConventionHandler {
            handler = { (notification: NSNotification) in (definition.handler.original as! ObserverConventionHandler)() }
        } else if self.handler is NotificationObserverHandler || self.handler is NotificationObserverConventionHandler {
            handler = self.handler
        } else {
            throw Observer.Error.UnrecognisedHandlerSignature
        }

        definition = NotificationObserverHandlerDefinition(name: self.name, observable: self.observable, queue: self.queue, handler: (original: self.handler, normalised: handler))
        return definition
    }
}