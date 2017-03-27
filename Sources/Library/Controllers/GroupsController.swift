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
        return try JSON(node: Group.all().makeNode(context: GroupResponseContext()))
    }

    /// POST: Add a new group entry.
    public func store(request: Request) throws -> ResponseRepresentable {
        var group = try request.group()
        guard let course = try Course.find(group.courseId) else {
            // Course doesn't exist
            return try Response(status: .notFound, headers: ["Content-Type" : "application/json"], body: JSON(node: ["failure": "Course does not exist"]))
        }
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
        return try JSON(node: group.makeNode(context: GroupResponseContext()))
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
        // D6 Defect: Duplicated users in response.
        return try JSON(node: ["members": (group.users().all() + group.users().all()).makeNode(context: UserSensitiveContext())])
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
        
        // D12 Defect: Missing check to see if student is enrolled in course
        
        
        
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
        // D8 Defect: user is not removed from group
        //try pivot.delete()
        return try JSON(node: ["Success": "User removed from group"])
    }

}
