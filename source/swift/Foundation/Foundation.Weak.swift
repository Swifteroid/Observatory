import Foundation

public class Weak
{
    public weak var value: AnyObject!

    public init(value: AnyObject) {
        self.value = value
    }
}