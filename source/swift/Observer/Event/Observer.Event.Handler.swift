import Foundation

public struct EventObserverHandler
{
    public typealias Global = (event: NSEvent) -> ()
    public typealias Local = (event: NSEvent) -> NSEvent?
}

public struct EventObserverConventionHandler
{
    public typealias Global = @convention(block) (event: NSEvent) -> ()
    public typealias Local = @convention(block) (event: NSEvent) -> NSEvent?
}