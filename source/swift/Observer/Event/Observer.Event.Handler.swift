import Foundation

public struct EventObserverHandler
{
    public typealias Global = (NSEvent) -> ()
    public typealias Local = (NSEvent) -> NSEvent?
}

public struct EventObserverConventionHandler
{
    public typealias Global = @convention(block) (NSEvent) -> ()
    public typealias Local = @convention(block) (NSEvent) -> NSEvent?
}