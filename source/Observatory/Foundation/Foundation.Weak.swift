import Foundation

open class Weak
{
    open weak var value: AnyObject!

    public init(value: AnyObject) {
        self.value = value
    }
}