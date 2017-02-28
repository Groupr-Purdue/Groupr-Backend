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
            store: store,
            show: show,
            modify: update,
            destroy: destroy
        )
    }

    /// GET /: Show all user entries.
    public func index(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: User.all().makeNode())
    }

    /// POST: Add a new user entry.
    public func store(request: Request) throws -> ResponseRepresentable {
        var newUser = try request.user()
        guard let password = request.json?["password"]?.string else {
            throw Abort.custom(status: .preconditionFailed, message: "missing password field")
        }
        newUser.password_hash = try self.droplet.hash.make(password)
        try newUser.save()
        return newUser
    }

    /// GET: Show the user entry.
    public func show(request: Request, user: User) throws -> ResponseRepresentable {
        return user
    }

    /// PUT: Update the user entry completely.
    public func update(request: Request, user: User) throws -> ResponseRepresentable {
        let newUser = try request.user()
        var user = user
        user.first_name = newUser.first_name
        user.last_name = newUser.last_name
        user.career_account = newUser.career_account
        try user.save()
        return user
    }

    /// DELETE: Delete the user entry and return the user that was deleted.
    public func destroy(request: Request, user: User) throws -> ResponseRepresentable {
        let ret_user = user
        try user.delete()
        return ret_user
    }
}
