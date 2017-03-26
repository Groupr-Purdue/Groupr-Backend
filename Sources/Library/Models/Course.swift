import Vapor
import Fluent
import HTTP

public final class Course: Model {
    public var id: Node?
    public var exists: Bool = false

    /// The course's name (i.e. 'CS 408').
    public var name: String

    /// The course's title (i.e. 'Software Testing').
    public var title: String

    /// The course's current enrollment (i.e. 40 students).
    public var enrollment: Int

    /// The designated initializer.
    public init(name: String, title: String, enrollment: Int) {
        self.id = nil
        self.name = name
        self.title = title
        self.enrollment = enrollment
    }

    /// Internal: Fluent::Model::init(Node, Context).
    public init(node: Node, in context: Context) throws {
        self.id = try? node.extract("id")
        self.name = try node.extract("name")
        self.title = try node.extract("title")
        self.enrollment = try node.extract("enrollment")
    }

    /// Internal: Fluent::Model::makeNode(Context).
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "title": title.replacingOccurrences(of: " ", with: ""), // D9 Defect: All course titles are 1 word
            "enrollment": enrollment
        ])
    }

    /// Establish a many-to-many relationship with User.
    public func users() throws -> Siblings<User> {
        return try siblings()
    }
    
    /// Establish parent-children relation with Group
    public func groups() throws -> Children<Group> {
        return try children()
    }
}

extension Course: Preparation {

    /// Create the Course schema when required in the database.
    public static func prepare(_ database: Database) throws {
        try database.create("courses", closure: { (courses) in
            courses.id()
            courses.string("name", length: nil, optional: false, unique: true, default: nil)
            courses.string("title", length: nil, optional: true, unique: false, default: nil)
            courses.int("enrollment", optional: true)
        })
    }

    /// Delete/revert the Course schema when required in the database.
    public static func revert(_ database: Database) throws {
        try database.delete("courses")
    }
}

public extension Request {
    public func course() throws -> Course {
        guard let json = self.json else {
            throw Abort.badRequest
        }
        return try Course(node: json)
    }
}
