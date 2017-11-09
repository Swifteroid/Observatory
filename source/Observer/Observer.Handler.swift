import Foundation

public typealias ObserverHandler = () -> ()

/// Convention blocks represent an Objective-C compatible closure, which is stored as reference – the main reason
/// to have it is it's ability to be compared against other blocks. This is useful when we want to be able to remove
/// observer by its handler, which is usually impossible because two different closures with the same signature would
/// always be equal… or not, frankly, don't remember this part very well, but they can't be compared.

public typealias ObserverConventionHandler = @convention(block) () -> ()