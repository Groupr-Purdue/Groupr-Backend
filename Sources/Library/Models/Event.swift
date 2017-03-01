import Vapor
import Fluent
import HTTP

public final class Event: Model {
    public var id: Node?
    public var exists: Bool = false

    /// The attached course id (where it was sent/triggered).
    public var course_id: String

    /// The attached user id (who sent/triggered it).
    public var user_id: String

    /// The event message (its contents).
    public var message: String

    /// The event timestamp (when it happened).
    public var timestamp: Int

    /// The designated initializer.
    public init(course_id: String, user_id: String, message: String, timestamp: Int) {
        self.id = nil
        self.course_id = course_id
        self.user_id = user_id
        self.message = message
        self.timestamp = timestamp
    }

    /// Internal: Fluent::Model::init(Node, Context).
    public init(node: Node, in context: Context) throws {
        self.id = try? node.extract("id")
        self.course_id = try node.extract("course_id")
        self.user_id = try node.extract("user_id")
        self.message = try node.extract("message")
        self.timestamp = try node.extract("timestamp")
    }

    /// Internal: Fluent::Model::makeNode(Context).
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "course_id": course_id,
            "user_id": user_id,
            "message": message,
            "timestamp": timestamp,
        ])
    }

    /// Define a one-to-one ER relationship with Course.
    public func course() throws -> Parent<Course> {
        return try parent(self.id) /*course_id*/
    }

    /// Define a one-to-one ER relationship with User.
    public func user() throws -> Parent<User> {
        return try parent(self.id) /*user_id*/
    }
}

extension Event: Preparation {

    /// Create the User schema when required in the database.
    public static func prepare(_ database: Database) throws {
        try database.create("events", closure: { (events) in
            events.id()
            events.parent(Course.self)
            events.parent(User.self)
            events.string("message", length: nil, optional: true, unique: false, default: nil)
            events.int("timestamp", optional: true, unique: false, default: nil)
        })
    }

    /// Delete/revert the User schema when required in the database.
    public static func revert(_ database: Database) throws {
        try database.delete("events")
    }
}

public extension Request {
    public func event() throws -> Event {
        guard let json = self.json else {
            throw Abort.badRequest
        }
        return try Event(node: json)
    }
}
