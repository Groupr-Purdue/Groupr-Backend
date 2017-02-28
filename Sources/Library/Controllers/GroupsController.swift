import Vapor
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

    /// GET /: Show all group entries.
    public func index(request: Request) throws -> ResponseRepresentable {
        let json = try JSON(node: Group.all().makeNode())
        return json
    }

    /// POST: Add a new group entry.
    public func store(request: Request) throws -> ResponseRepresentable {
        var group = try request.group()
        try group.save()
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
        return ret_group
    }
}
