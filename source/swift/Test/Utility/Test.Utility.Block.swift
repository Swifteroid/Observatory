@testable import Observatory
import Nimble
import XCTest

public class BlockUtilityTestCase: XCTestCase
{
    /*
    Verify that block weakening works as expected.
    */
    public func testWeaken() {

        // Using the method directly will create retain cycle, while passing weakened method will not, after
        // deinitialising both variables, one weak value must be lost and one retained.

        var foo1: Foo! = Foo()
        var foo2: Foo! = Foo()

        weak var unownedFoo1: Foo! = foo1;
        weak var unownedFoo2: Foo! = foo2;

        let handler1: Any = foo1.handle
        let handler2: Any = BlockUtility.weaken(foo2, method: Foo.handle)

        expect(unownedFoo1).notTo(beNil())
        expect(unownedFoo2).notTo(beNil())

        foo1 = nil
        foo2 = nil

        expect(unownedFoo1).notTo(beNil())
        expect(unownedFoo2).to(beNil())

        // Both handlers are not nil even though `foo2` no longer exists. You'll get a massive fail if try
        // invoking it. Typically observers get automatically deinitialised and release all references.

        expect(handler1).notTo(beNil())
        expect(handler2).notTo(beNil())
    }
}

private class Foo: NotificationObserverHandlerProtocol
{
    private func handle() {
    }
}