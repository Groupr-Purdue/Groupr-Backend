import Vapor
import Fluent
import HTTP

public final class GroupsController: ResourceRepresentable {
    var droplet: Droplet
    public init(droplet: Droplet) {
        self.droplet = droplet
    }

    public func makeResource() -> Resource<Group> {
        return Resource(
            index: index,
            store: store,
            show: show,
            destroy: destroy
        )
    }
    
    public func registerRoutes() {
        droplet.group("groups", ":id") { groups in
            groups.get("users", handler: users)
            groups.post("users", handler: addUser)
            groups.delete("users", handler: leaveGroup)
        }
    }

    /// GET /: Show all group entries.
    public func index(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: Group.all().makeNode())
    }

    /// POST: Add a new group entry.
    public func store(request: Request) throws -> ResponseRepresentable {
        var group = try request.group()
        try group.save()
        try RealtimeController.send(try JSON(node: [
            "endpoint": "groups",
            "method": "store",
            "item": group
        ]))
        return group
    }

    /// GET: Show the group entry.
    public func show(request: Request, group: Group) throws -> ResponseRepresentable {
        return group
    }

    /// DELETE: Delete the group entry and return the group that was deleted.
    public func destroy(request: Request, group: Group) throws -> ResponseRepresentable {
        let ret_group = group
        try group.delete()
        try RealtimeController.send(try JSON(node: [
            "endpoint": "groups",
            "method": "destroy",
            "item": ret_group
        ]))
        return ret_group
    }
    
    public func users(request: Request) throws -> ResponseRepresentable {
        guard let groupId = request.parameters["id"]?.int else {
            // Bad group id in request
            throw Abort.badRequest
        }
        guard let group = try Group.find(groupId) else {
            // Group doesn't exist
            throw Abort.notFound
        }
        return try JSON(node: ["members": group.users().all().makeNode(context: UserSensitiveContext())])
    }
    
    public func addUser(request: Request) throws -> ResponseRepresentable {
        guard let groupId = request.parameters["id"]?.int else {
            // Bad group id in request
            throw Abort.badRequest
        }
        guard let group = try Group.find(groupId) else {
            // Group doesn't exist
            throw Abort.notFound
        }
        guard let user = try User.authenticateWithToken(fromRequest: request) else {
            // Auth token not provided or token not valid
            return try JSON(node: ["error" : "Not authorized"]).makeResponse()
        }
        let users = try group.users().all()
        let exists = users.contains { (User) -> Bool in
            for u in users {
                if u.id == user.id {
                    return true
                }
            }
            return false
        }
        if exists {
            return try JSON(node: ["error" : "User already in group"]).makeResponse()
        }
        var pivot = Pivot<Group, User>(group, user)
        try pivot.save()
        
        return try JSON(node: ["Success": "User added to group"])
    }
    
    func leaveGroup(request: Request) throws -> ResponseRepresentable {
        guard let groupId = request.parameters["id"]?.int else {
            // Bad group id in request
            throw Abort.badRequest
        }
        guard let group = try Group.find(groupId) else {
            // Group doesn't exist
            throw Abort.notFound
        }
        guard let user = try User.authenticateWithToken(fromRequest: request) else {
            // Auth token not provided or token not valid
            return try JSON(node: ["error" : "Not authorized"]).makeResponse()
        }
        let pivot = try Pivot<Group, User>.query().filter("group_id", groupId).filter("user_id", user.id!)
        try pivot.delete()
        return try JSON(node: ["Success": "User removed from group"])
    }
    
}
