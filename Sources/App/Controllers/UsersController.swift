import Vapor
import HTTP

final class UsersController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        let json = try JSON(node: User.all().makeNode())
        return json
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        var user = try request.user()
        try user.save()
        return user
    }
    
    func show(request: Request, user: User) throws -> ResponseRepresentable {
        return user
    }
    
    func update(request: Request, user: User) throws -> ResponseRepresentable {
        let newUser = try request.user()
        var user = user
        user.first_name = newUser.first_name
        user.last_name = newUser.last_name
        user.career_account = newUser.career_account
        try user.save()
        return user
    }
    
    func destroy(request: Request, user: User) throws -> ResponseRepresentable {
        try user.delete()
        return JSON([:])
    }
    
    public func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            store: store,
            show: show,
            modify: update,
            destroy: destroy
        )
    }
}

extension Request {
    func user() throws -> User {
        guard let json = self.json else {
            throw Abort.badRequest
        }
        return try User(node: json)
    }
}
