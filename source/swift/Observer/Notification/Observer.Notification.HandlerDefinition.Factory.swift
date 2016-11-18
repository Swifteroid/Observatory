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
        let originalHandler: Any = self.handler
        var normalisedHandler: Any

        if originalHandler is ObserverHandler {
            normalisedHandler = { (notification: NSNotification) in (originalHandler as! ObserverHandler)() }
        } else if originalHandler is ObserverConventionHandler {
            normalisedHandler = { (notification: NSNotification) in (originalHandler as! ObserverConventionHandler)() }
        } else if originalHandler is NotificationObserverHandler || originalHandler is NotificationObserverConventionHandler {
            normalisedHandler = originalHandler
        } else {
            throw Observer.Error.UnrecognisedHandlerSignature
        }

        definition = NotificationObserverHandlerDefinition(name: self.name, observable: self.observable, queue: self.queue, handler: (original: originalHandler, normalised: normalisedHandler))
        return definition
    }
}