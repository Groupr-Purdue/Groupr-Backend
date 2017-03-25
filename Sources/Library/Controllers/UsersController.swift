import Vapor
import HTTP
import Foundation

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
        droplet.group("users", ":id") { users in
            users.get("courses", handler: courses)
        }
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

    /// Patch: Update the user entry.
    public func update(request: Request, user: User) throws -> ResponseRepresentable {
        guard try User.authorize(user, withRequest: request) else {
            return try JSON(node: ["error" : "Not authorized"])
        }
        let newUser = try request.user()
        var user = user
        if let firstName = newUser.first_name { user.first_name = firstName }
        if let lastName = newUser.last_name { user.first_name = lastName }
        if let careerAccount = newUser.career_account { user.career_account = careerAccount }
        try user.save()
        try RealtimeController.send(try JSON(node: [
            "endpoint": "users",
            "method": "update",
            "item": user
        ]))
        return try user.userJson()
    }

    /// DELETE: Delete the user entry and return a HTTP 204 No-Content status
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
    public struct StderrOutputStream: TextOutputStream {
        public mutating func write(_ string: String) { fputs(string, stderr) }
    }
    public var errStream = StderrOutputStream()
    

    /// POST: Registers the user entry and returns the user
    public func register(request: Request) throws -> ResponseRepresentable {
        guard let career_account = request.json?["career_account"]?.string,
        let rawPassword = request.json?["password"]?.string,
        let firstName = request.json?["first_name"]?.string,
        let lastName = request.json?["last_name"]?.string
        else {
            return try JSON(node: ["error": "Missing credentials"])
        }
        guard let newUser = try? User.register(career_account: career_account, rawPassword: rawPassword, first_name: firstName, last_name: lastName) else {
            let response = Response(status: .conflict, headers: ["Content-Type": "text/json"], body: try JSON(node: ["error" : "Account already registered"]))
            return response
        }
        return try newUser.userJson()
    }

    /// GET: Returns the courses the user is enrolled in
    public func courses(request: Request) throws -> ResponseRepresentable {
        guard let userId = request.parameters["id"]?.int else {
            throw Abort.badRequest
        }
        guard let user = try User.find(userId) else {
            throw Abort.notFound
        }
        guard try User.authorize(user, withRequest: request) else {
            return try JSON(node: ["error" : "Not authorized"]).makeResponse()
        }
        return try user.courses().all().makeJSON()
    }
}
