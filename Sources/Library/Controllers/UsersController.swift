import Vapor
import HTTP

public final class UsersController: ResourceRepresentable {
    var droplet: Droplet
    public init(droplet: Droplet) {
        self.droplet = droplet
    }

    // replace, clear, about* -- ?
    public func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            show: show,
            modify: update,
            destroy: destroy
        )
    }

    public func registerRoutes() {
      droplet.post("register", handler: register)
    }

    /// GET : Show all user entries.
    public func index(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: User.all().makeNode(context: UserSensitiveContext()))
    }
    
    /// GET: Show the user entry.
    public func show(request: Request, user: User) throws -> ResponseRepresentable {
        guard try User.authorize(user, withRequest: request) else {
            return try JSON(node: ["error" : "Not authorized"])
        }
        
        return try user.userJson()
    }

    /// PUT: Update the user entry completely.
    public func update(request: Request, user: User) throws -> ResponseRepresentable {
        guard try User.authorize(user, withRequest: request) else {
            return try JSON(node: ["error" : "Not authorized"])
        }
        let newUser = try request.user()
        var user = user
        user.first_name = newUser.first_name
        user.last_name = newUser.last_name
        user.career_account = newUser.career_account
        try user.save()
        try RealtimeController.send(try JSON(node: [
            "endpoint": "users",
            "method": "update",
            "item": user
        ]))
        return user
    }

    /// DELETE: Delete the user entry and return the user that was deleted.
    public func destroy(request: Request, user: User) throws -> ResponseRepresentable {
        guard try User.authorize(user, withRequest: request) else {
            return try JSON(node: ["error" : "Not authorized"]).makeResponse()
        }
        let ret_user = user
        try user.delete()
        try RealtimeController.send(try JSON(node: [
            "endpoint": "users",
            "method": "destroy",
            "item": ret_user
        ]))
        return try Response(status: .noContent, json: JSON(nil))
    }

    /// POST: Registers the user entry and returns the user
    public func register(request: Request) throws -> ResponseRepresentable {
        guard let career_account = request.json?["career_account"]?.string,
        let rawPassword = request.json?["password"]?.string
        else {
            return JSON("Missing career_account or password")
        }
        let newUser = try User.register(career_account: career_account, rawPassword: rawPassword)
        return try newUser.userJson()
    }
}
