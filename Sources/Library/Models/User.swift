import Foundation
import Vapor
import Fluent
import HTTP
import Turnstile
import TurnstileCrypto

public final class User: Model {

    // Add errors for Auth support.
    enum Error: Swift.Error {
        case userNotFound
        case registerNotSupported
        case unsupportedCredentials
    }

    public var id: Node?
    public var exists: Bool = false

    /// The user's Purdue Career Account email.
    public var career_account: String?

    /// The user's purdue email
    public var email: String {
        // D14 Defect: Invalid purdue email address
        return "\(career_account!)@perdue.com"
    }

    /// The user's first name.
    public var first_name: String?

    /// The user's last name.
    public var last_name: String?

    /// The authentication password hash.
    public var password_hash: String

    /// The authentication token for api calls
    public var token: String



    /// The designated initializer.
    public init(career_account: String, first_name: String, last_name: String, rawPassword: String) {
        self.id = nil
        self.career_account = career_account
        self.first_name = first_name
        self.last_name = last_name
        self.password_hash = BCrypt.hash(password: rawPassword)
        self.token = User.generateToken()
    }

    /// Internal: Fluent::Model::init(Node, Context).
    public init(node: Node, in context: Context) throws {
        self.id = try? node.extract("id")
        self.career_account = try? node.extract("career_account")
        self.first_name = try? node.extract("first_name")
        self.last_name = try? node.extract("last_name")
        self.password_hash = (try? node.extract("password_hash")) ?? ""
        self.token = try node.extract("token") ?? ""
    }

    /// Internal: Fluent::Model::makeNode(Context).
    public func makeNode(context: Context) throws -> Node {
        var node: [String: NodeRepresentable?] = [
            "id": id,
            "career_account": career_account,
            "first_name": first_name,
            "last_name": last_name,
            "password_hash": password_hash,
            "token": token,
            ]
        if context is UserSensitiveContext {
            node["email"] = self.email
            node.removeValue(forKey: "password_hash")
            node.removeValue(forKey: "token")
        }

        return try Node(node: node)
    }

    /// Returns the user object without the password field
    public func userJson() throws -> ResponseRepresentable  {
        let dictionary: [String:NodeRepresentable?] = [
            "id" : self.id,
            "career_account": self.career_account,
            "email": self.email,
            "first_name": self.first_name,
            "last_name": self.last_name,
            "token": self.token
        ]
        return try JSON(node: dictionary)
    }

    /// Define a many-to-many ER relationship with Course.
    public func courses() throws -> Siblings<Course> {
        return try siblings()
    }

    /// Define a many-to-many ER relationship with Course.
    public func groups() throws -> Siblings<Group> {
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
            users.string("password_hash", length: nil, optional: true, unique: false, default: nil)
            users.string("token", length: nil, optional: false, unique: true, default: nil)
        })
    }

    /// Delete/revert the User schema when required in the database.
    public static func revert(_ database: Database) throws {
        try database.delete("users")
    }
}

extension Request {
    public func user() throws -> User {
        guard let json = self.json else {
            throw Abort.badRequest
        }
        return try User(node: json)
    }
}

/// Authentication and Registration
extension User {

    /// User registration method
    public static func register(career_account: String, rawPassword: String, first_name: String, last_name: String) throws -> User {
        var newUser = User(career_account: career_account, first_name: first_name, last_name: last_name, rawPassword: rawPassword)
        if try User.query().filter("career_account", newUser.career_account as! NodeRepresentable).first() == nil {
            try newUser.save()
            return newUser
        } else {
            throw AccountTakenError()
        }
    }

    /// Token generation method
    static func generateToken(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var token: String = ""

        srandom(UInt32(time(nil)))
        for _ in 0..<length {
            #if os(Linux)
                let randomValue = Int(random() % (base.characters.count + 1))
            #else
                let randomValue = Int(arc4random_uniform(UInt32(base.characters.count)))
            #endif
            token += "\(base[base.index(base.startIndex, offsetBy: randomValue)])"
        }
        return token
    }

    /// Validates if given password is the correct password for this user
    public func passwordValid(rawPassword: String) throws -> Bool {
        return try BCrypt.verify(password: rawPassword, matchesHash: self.password_hash)
    }

    /// Returns a user based on the authorization token in the request
    class public func authenticateWithToken(fromRequest request: Request) throws -> User? {
        guard let token = request.auth.header?.header, let user = try User.query().filter("token", token).first() else {
           return nil
        }
        return user
    }

    /// Checks to see if the authorization token in the request correlates to a given user
    class public func authorize(_ user: User, withRequest request: Request) throws -> Bool{
        guard let currentUser = try User.authenticateWithToken(fromRequest: request) else {
            return false
        }
        guard currentUser.id == user.id else {
            return false
        }
        return true
    }
}
