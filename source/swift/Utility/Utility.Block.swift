import Foundation

public struct BlockUtility
{
    public typealias Block = () -> Void

    /*
    I haven't figured out if this is more scare than exciting or the opposite, but this is a piece of
    something… Basically, if we have an object that has a callback method / handler and we pass it into
    another object we will endup with a retain cycle and unhandled memory leak. So, whenerver
    this happens, we must create a weak handler and pass only that to the observer.

    ```
    // Call from inside some instance…
    BlockUtility.weaken(self, method: SELF.handler))
    ```
    */
    public static func weaken<T:AnyObject>(instance: T, method: (T) -> Block) -> Block {
        return { [unowned instance] in method(instance)() }
    }
}