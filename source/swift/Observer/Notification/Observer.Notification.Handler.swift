import Foundation

public typealias NotificationObserverHandler = (notification: NSNotification) -> ()
public typealias NotificationObserverConventionHandler = @convention(block) (notification: NSNotification) -> ()