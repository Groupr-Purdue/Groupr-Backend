import XCTest
@testable import Library

class RealTimeTests: XCTestCase {

    // Description of the test goes here.
    public func test1() {
        let test_hash = "213809j23lhkjg42397d8saklj21839uildkjsa";
        XCTAssertEqual(test_hash, test_hash)
    }
}

#if os(Linux)
public extension RealTimeTests {
    public static var allTests : [(String, (RealTimeTests) -> () throws -> Void)] {
        return [
            ("test1", test1),
        ]
    }
}
#endif
