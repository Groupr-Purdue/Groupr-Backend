import Vapor
import HTTP

public final class AuthController {
    var droplet: Droplet
    public init(droplet: Droplet) {
        self.droplet = droplet
    }

    /// GET /: Returns your own user when authenticated.
    public func me(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: request.auth_user().makeNode())
    }

    /// POST: Authenticates user with password and returns the respective user
    public func login(request: Request) throws -> ResponseRepresentable {
        guard let careerAccount = request.json?["career_account"]?.string, let user = try User.query().filter("career_account", careerAccount).first() else {
            return try JSON(node: ["error": "Incorrect career account or password"])
        }
        
        guard let rawPassword = request.json?["password"]?.string, try user.passwordValid(rawPassword: rawPassword) else {
            return try JSON(node: ["error": "Incorrect career account or password"])
        }
        
        return try user.userJson()
    }

    /// DELETE: Deauthenticate user by expiring the current user token and generating a new one
    public func logout(request: Request) throws -> ResponseRepresentable {
        guard let token = request.auth.header?.header, var user = try User.query().filter("token", token).first() else {
            return try JSON(node: ["error": "Not Authenticated"])
        }
        user.token = User.generateToken()
        try user.save()
        return try JSON(node: ["success": "User logged out"])
    }
}
