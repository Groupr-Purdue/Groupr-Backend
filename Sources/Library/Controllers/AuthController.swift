import Vapor
import HTTP

/// Note: doesn't support registering.
public final class AuthController {
    var droplet: Droplet
    public init(droplet: Droplet) {
        self.droplet = droplet
    }

    /// GET /: Returns your own user when authenticated.
    public func me(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: request.auth_user().makeNode())
    }

    /// POST: Authenticates with the platform as a user.
    public func login(request: Request) throws -> ResponseRepresentable {
        //let users = try User.query()
        //              .filter("career_account", x)
        //              .filter("password_hash", y)
        //              .all()
        /*
        guard let id = req.data["id"]?.string else {
            throw Abort.badRequest
        }
        let creds = try Identifier(id: id)
        try req.auth.login(creds)
        return try JSON(node: ["message": "success"])
        */
        var event = try request.event()
        try event.save()
        return event
    }

    /// DELETE: Delete the group entry and return the group that was deleted.
    public func logout(request: Request) throws -> ResponseRepresentable {
        request.storage["token"] = nil
        return try JSON(node: ["success": true])
    }


/*
    func register(request: Request) throws -> ResponseRepresentable {
        // Get our credentials
        guard let username = request.data["username"]?.string, let password = request.data["password"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "Missing username or password")
        }
        let credentials = UsernamePassword(username: username, password: password)


        // Try to register the user
        do {
            try _ = User.register(credentials: credentials)
            try request.auth.login(credentials)

            return try JSON(node: ["success": true, "user": request.user().makeNode()])
        } catch let e as TurnstileError {
            throw Abort.custom(status: Status.badRequest, message: e.description)
        }
    }

    func login(request: Request) throws -> ResponseRepresentable {
        // Get our credentials
        guard let username = request.data["username"]?.string, let password = request.data["password"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "Missing username or password")
        }
        let credentials = UsernamePassword(username: username, password: password)

        do {
            try request.auth.login(credentials)
            return try JSON(node: ["success": true, "user": request.user().makeNode()])
        } catch _ {
            throw Abort.custom(status: Status.badRequest, message: "Invalid email or password")
        }
    }

    func logout(request: Request) throws -> ResponseRepresentable {
        // Invalidate the current access token
        var user = try request.user()
        user.token = nil
        try user.save()

        // Clear the session
        request.subject.logout()
        return try JSON(node: ["success": true])
    }

    func validateAccessToken(request: Request) throws -> ResponseRepresentable {
        var user = try request.user()
        guard let _ = user.token else {
            throw Abort.badRequest
        }

        // Check if the token is expired, or invalid and generate a new one
        if try user.validateToken() {
            try user.save()
        }

        return try JSON(node: ["success": true])
    }
*/
}
