import Vapor
import Fluent

public final class User: Model {
    public var id: Node?
    public var exists: Bool = false

    public var first_name: String
    public var last_name: String
    public var career_account: String

    public init(career_account: String, first_name: String, last_name: String) {
        self.id = nil
        self.first_name = first_name
        self.last_name = last_name
        self.career_account = career_account
    }

    public init(node: Node, in context: Context) throws {
        self.id = try node.extract("id")
        self.first_name = try node.extract("first_name")
        self.last_name = try node.extract("last_name")
        self.career_account = try node.extract("career_account")
    }

    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "first_name": first_name,
            "last_name": last_name,
            "career_account": career_account
        ])
    }

    public static func prepare(_ database: Database) throws {
        try database.create("users", closure: { (users) in
            users.id()
            users.string("first_name", length: nil, optional: true, unique: false, default: nil)
            users.string("last_name", length: nil, optional: true, unique: false, default: nil)
            users.string("career_account", length: nil, optional: false, unique: true, default: nil)
        })
    }

    public static func revert(_ database: Database) throws {
        try database.delete("users")
    }

    public func courses() throws -> Siblings<Course> {
        return try siblings()
    }
}
