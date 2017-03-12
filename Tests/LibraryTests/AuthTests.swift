import XCTest
@testable import Library

class AuthTests: XCTestCase {

    // Description of the test goes here.
    public func test1() {
        let test_hash = "213809j23lhkjg42397d8saklj21839uildkjsa";
        XCTAssertEqual(test_hash, test_hash)
    }
}

#if os(Linux)
public extension AuthTests {
    public static var allTests : [(String, (AuthTests) -> () throws -> Void)] {
        return [
            ("test1", test1),
        ]
    }
}
#endif
