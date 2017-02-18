import Foundation

public struct CarbonEventObserverHandler
{
    public typealias Global = (CGEvent) -> ()
    public typealias Local = (CGEvent) -> CGEvent?
}

public struct CarbonEventObserverConventionHandler
{
    public typealias Global = @convention(block) (CGEvent) -> ()
    public typealias Local = @convention(block) (CGEvent) -> CGEvent?
}

public struct AppKitEventObserverHandler
{
    public typealias Global = (NSEvent) -> ()
    public typealias Local = (NSEvent) -> NSEvent?
}

public struct AppKitEventObserverConventionHandler
{
    public typealias Global = @convention(block) (NSEvent) -> ()
    public typealias Local = @convention(block) (NSEvent) -> NSEvent?
}