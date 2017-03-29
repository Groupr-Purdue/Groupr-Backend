import XCTest
import Vapor
import Fluent
import HTTP
@testable import Library

class CourseTests: XCTestCase {
    
    var course1: Course!
    var course2: Course!
    var node: Node!
    
    override func setUp() {
        let courseNodeCredentials: [String: Node] = [
            "name": "CS 240",
            "title": "Programming in C",
            "enrollment": 100
        ]
        node = Node(courseNodeCredentials)
        course2 = try? Course(node: node)
        course1 = Course(name: "CS 408", title: "Software Testing", enrollment: 50)
    }
    
    /// Test presence and accurancy of course 1 name property
    public func testCourse1NameProperty() throws {
        XCTAssertEqual(course1.name, "CS 408")
    }
    
    /// Test presence and accurancy of course 1 title property
    public func testCourse1TitleProperty() throws {
        XCTAssertEqual(course1.title, "Software Testing")
    }
    
    /// Test presence and accurancy of course 1 enrollment property
    public func testCourse1EnrollmentProperty() throws {
        XCTAssertEqual(course1.enrollment, 50)
    }
    
    /// Test course 1 property initialization for Fluent entity
    public func testCourse1FluentInitialization() throws {
        XCTAssertNil(course1.id)
        XCTAssertFalse(course1.exists)
    }
    
    /// Test presence and accurancy of course 2 name property
    public func testCourse2NameProperty() throws {
        XCTAssertEqual(course2.name, "CS 240")
    }
    
    /// Test presence and accurancy of course 2 title property
    public func testCourse2TitleProperty() throws {
        XCTAssertEqual(course2.title, "Programming in C")
    }
    
    /// Test presence and accurancy of course 2 enrollment property
    public func testCourse2EnrollmentProperty() throws {
        XCTAssertEqual(course2.enrollment, 100)
    }
    
    /// Test course 2 property initialization for Fluent entity
    public func testCourse2FluentInitialization() throws {
        XCTAssertNil(course2.id)
        XCTAssertFalse(course2.exists)
    }

}

#if os(Linux)
public extension CourseTests {
    public static var allTests : [(String, (CourseTests) -> () throws -> Void)] {
        return [
            ("test1", test1),
        ]
    }
}
#endif
