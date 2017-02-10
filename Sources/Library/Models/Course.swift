import Vapor
import Fluent

public final class Course: Model {
    public var id: Node?
    public var exists: Bool = false

    public var name: String
    public var title: String
    public var enrollment: Int

    public init(name: String, title: String, enrollment: Int) {
        self.id = nil
        self.name = name
        self.title = title
        self.enrollment = enrollment
    }

    public init(node: Node, in context: Context) throws {
        self.id = try node.extract("id")
        self.name = try node.extract("name")
        self.title = try node.extract("title")
        self.enrollment = try node.extract("enrollment")
    }

    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "title": title,
            "enrollment": enrollment
        ])
    }

    public static func prepare(_ database: Database) throws {
        try database.create("courses", closure: { (courses) in
            courses.id()
            courses.string("name", length: nil, optional: false, unique: true, default: nil)
            courses.string("title", length: nil, optional: true, unique: false, default: nil)
            courses.int("enrollment", optional: true)
        })
    }

    public static func revert(_ database: Database) throws {
        try database.delete("courses")
    }

    public func users() throws -> Siblings<User> {
        return try siblings()
    }
}
