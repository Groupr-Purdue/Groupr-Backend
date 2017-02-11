import Vapor
import Fluent

public final class User: Model {
    public var id: Node?
    public var exists: Bool = false

    /// The user's Purdue Career Account email.
    public var career_account: String

    /// The user's first name.
    public var first_name: String

    /// The user's last name.
    public var last_name: String

    /// The designated initializer.
    public init(career_account: String, first_name: String, last_name: String) {
        self.id = nil
        self.career_account = career_account
        self.first_name = first_name
        self.last_name = last_name
    }

    /// Internal: Fluent::Model::init(Node, Context).
    public init(node: Node, in context: Context) throws {
        self.id = try node.extract("id")
        self.career_account = try node.extract("career_account")
        self.first_name = try node.extract("first_name")
        self.last_name = try node.extract("last_name")
    }

    /// Internal: Fluent::Model::makeNode(Context).
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "career_account": career_account,
            "first_name": first_name,
            "last_name": last_name,
        ])
    }

    /// Define a many-to-many ER relationship with Course.
    public func courses() throws -> Siblings<Course> {
        return try siblings()
    }
}

extension User: Preparation {

    /// Create the User schema when required in the database.
    public static func prepare(_ database: Database) throws {
        try database.create("users", closure: { (users) in
            users.id()
            users.string("career_account", length: nil, optional: false, unique: true, default: nil)
            users.string("first_name", length: nil, optional: true, unique: false, default: nil)
            users.string("last_name", length: nil, optional: true, unique: false, default: nil)
        })
    }

    /// Delete/revert the User schema when required in the database.
    public static func revert(_ database: Database) throws {
        try database.delete("users")
    }
}
