import Vapor
import Fluent
import Auth
import HTTP

extension User: Auth.User {
    public static func authenticate(credentials: Credentials) throws -> Auth.User {
        let user: User?

        switch credentials {
        case let id as Identifier:
            user = try User.find(id.id)
        case let accessToken as AccessToken:
            guard let user = try User.query().filter("access_token", accessToken.string).first() else {
                throw Abort.custom(status: .forbidden, message: "Invalid access token.")
            }
            return user
        default:
            throw Abort.custom(status: .badRequest, message: "Invalid credentials.")
        }
        guard let u = user else {
            throw Abort.custom(status: .badRequest, message: "User not found")
        }
        return u
    }

    public static func register(credentials: Credentials) throws -> Auth.User {
        throw Abort.custom(status: .badRequest, message: "Register not supported.")
    }
}

extension Request {
    public func auth_user() throws -> User {
        guard let user = try auth.user() as? User else {
            throw Abort.custom(status: .badRequest, message: "Invalid user type.")
        }
        return user
    }
}
