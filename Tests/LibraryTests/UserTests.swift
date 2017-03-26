import XCTest
import Vapor
import Fluent
import TurnstileCrypto
@testable import Library

class UserTests: XCTestCase {
    
    /// Test accuracy of user properties after initialization
    public func testCreateUserProperties() throws {
        let user = User(career_account: "career_account", first_name: "first_name", last_name: "last_name", rawPassword: "password")
        XCTAssertEqual(user.career_account, "career_account")
        XCTAssertEqual(user.first_name, "first_name")
        XCTAssertEqual(user.last_name, "last_name")
        XCTAssertNil(user.id)
    }
    
    /// Test if passwords are hashed on user creation
    public func testUserPasswordHash() throws {
        let user = User(career_account: "career_account", first_name: "first_name", last_name: "last_name", rawPassword: "password")
        XCTAssertTrue(try user.passwordValid(rawPassword: "password"))
    }
    
}

#if os(Linux)
public extension UserTests {
    public static var allTests : [(String, (UserTests) -> () throws -> Void)] {
        return [
            ("testCreateUserProperties", testCreateUserProperties),
            ("testUserPasswordHash", testUserPasswordHash)
        ]
    }
}
#endif
