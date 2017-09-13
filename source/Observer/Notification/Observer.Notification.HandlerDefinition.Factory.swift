import Foundation

open class NotificationObserverHandlerDefinitionFactory
{
    open var name: Notification.Name
    open var observable: AnyObject?
    open var queue: OperationQueue?
    open var handler: Any

    // MARK: -

    public init(name: Notification.Name, observable: AnyObject?, queue: OperationQueue?, handler: Any) {
        self.name = name
        self.observable = observable
        self.queue = queue
        self.handler = handler
    }

    // MARK: -

    open func construct() throws -> NotificationObserverHandlerDefinition {
        var definition: NotificationObserverHandlerDefinition!
        let originalHandler: Any = self.handler
        var normalisedHandler: Any

        if originalHandler is ObserverHandler {
            normalisedHandler = { (notification: Notification) in (originalHandler as! ObserverHandler)() }
        } else if originalHandler is ObserverConventionHandler {
            normalisedHandler = { (notification: Notification) in (originalHandler as! ObserverConventionHandler)() }
        } else if originalHandler is NotificationObserverHandler || originalHandler is NotificationObserverConventionHandler {
            normalisedHandler = originalHandler
        } else {
            throw Observer.Error.unrecognisedHandlerSignature
        }

        definition = NotificationObserverHandlerDefinition(name: self.name, observable: self.observable, queue: self.queue, handler: (original: originalHandler, normalised: normalisedHandler))
        return definition
    }
}