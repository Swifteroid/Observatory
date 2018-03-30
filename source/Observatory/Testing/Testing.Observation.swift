import Nimble

/// Simple observation object for tracking down and asserting observations during testing.

internal class Observation
{
    internal private(set) var count: Int = 0

    internal func make() {
        self.count += 1
    }

    internal func reset() {
        self.count = 0
    }

    internal func assert(count: Int? = nil, reset: Bool? = nil) {
        if let count: Int = count {
            expect(self.count).to(equal(count))
        } else {
            expect(self.count).to(beGreaterThan(0))
        }

        if reset ?? true {
            self.reset()
        }
    }
}