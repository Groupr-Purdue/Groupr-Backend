import Vapor
import Fluent

public final class Auth: Model {
    public var id: Node?
    public var exists: Bool = false

    /// The authentication password hash.
    public var password_hash: String

    /// The designated initializer.
    public init(password_hash: String) {
        self.id = nil
        self.password_hash = password_hash
    }

    /// Internal: Fluent::Model::init(Node, Context).
    public init(node: Node, in context: Context) throws {
        self.id = try node.extract("id")
        self.password_hash = try node.extract("password_hash")
    }

    /// Internal: Fluent::Model::makeNode(Context).
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "password_hash": password_hash
        ])
    }

    /// Define a one-to-one ER parent relationship with User.
    public func owner() throws -> Parent<User> {
        return try parent(id)
    }
}

extension Auth {

    /// Create the User schema when required in the database.
    public static func prepare(_ database: Database) throws {
        try database.create("auth", closure: { (users) in
            users.id()
            users.string("password_hash", length: nil, optional: false, unique: false, default: nil)
        })
    }

    /// Delete/revert the User schema when required in the database.
    public static func revert(_ database: Database) throws {
        try database.delete("auth")
    }
}
