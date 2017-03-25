import Vapor
import Fluent
import HTTP

public final class CoursesController: ResourceRepresentable {
    var droplet: Droplet
    public init(droplet: Droplet) {
        self.droplet = droplet
    }

    // replace, clear, about* -- ?
    public func makeResource() -> Resource<Course> {
        return Resource(
            index: index,
            store: store,
            show: show,
            modify: update,
            destroy: destroy
        )
    }

    public func registerRoutes() {
        droplet.group("courses", ":id") { courses in
            courses.get("users", handler: users)
            courses.post("users", handler: addUser)
            courses.get("groups", handler: groups)
            courses.post("groups", handler: addGroup)
        }
    }


    /// GET /: Show all course entries.
    public func index(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: Course.all().makeNode())
    }

    /// POST: Add a new course entry.
    public func store(request: Request) throws -> ResponseRepresentable {
        var course = try request.course()
        try course.save()
        try RealtimeController.send(try JSON(node: [
            "endpoint": "courses",
            "method": "store",
            "item": course
        ]))
        return course
    }

    /// GET: Show the course entry.
    public func show(request: Request, course: Course) throws -> ResponseRepresentable {
        return course
    }

    /// PUT: Update the course entry completely.
    public func update(request: Request, course: Course) throws -> ResponseRepresentable {
        let newCourse = try request.course()
        var course = course
        course.title = newCourse.title
        course.name = newCourse.name
        course.enrollment = newCourse.enrollment
        try course.save()
        try RealtimeController.send(try JSON(node: [
            "endpoint": "courses",
            "method": "update",
            "item": course
        ]))
        return course
    }

    /// DELETE: Delete the course entry and return the course that was deleted.
    public func destroy(request: Request, course: Course) throws -> ResponseRepresentable {
        let ret_course = course
        try course.delete()
        try RealtimeController.send(try JSON(node: [
            "endpoint": "courses",
            "method": "destroy",
            "item": ret_course
        ]))
        return ret_course
    }

    /// GET: Returns the users enrolled in a course
    public func users(request: Request) throws -> ResponseRepresentable {
        guard let courseId = request.parameters["id"]?.int else {
            // Bad course id in request
            throw Abort.badRequest
        }
        guard let course = try Course.find(courseId) else {
            // Course doesn't exist
            throw Abort.notFound
        }
        guard let user = try User.authenticateWithToken(fromRequest: request) else {
            // Auth token not provided or token not valid
            return try JSON(node: ["error" : "Not authorized"]).makeResponse()
        }

        return try JSON(node: course.users().all().makeNode(context: UserSensitiveContext()))
    }

    /// POST: Adds a user to a course
    public func addUser(request: Request) throws -> ResponseRepresentable {
        guard let courseId = request.parameters["id"]?.int else {
            // Bad course id in request
            throw Abort.badRequest
        }
        guard let course = try Course.find(courseId) else {
            // Course doesn't exist
            throw Abort.notFound
        }
        guard let user = try User.authenticateWithToken(fromRequest: request) else {
            // Auth token not provided or token not valid
            return try JSON(node: ["error" : "Not authorized"]).makeResponse()
        }
        let users = try course.users().all()
        let exists = users.contains { (User) -> Bool in
            for u in users {
                if u.id == user.id {
                    return true
                }
            }
            return false
        }
        if exists {
            return try JSON(node: ["error" : "User already enrolled"]).makeResponse()
        }
        var pivot = Pivot<Course, User>(course, user)
        try pivot.save()

        return try JSON(node: ["Success": "User added"])
    }

    public func groups(request: Request) throws -> ResponseRepresentable {
        guard let courseId = request.parameters["id"]?.int else {
            // Bad course id in request
            throw Abort.badRequest
        }
        guard let course = try Course.find(courseId) else {
            // Course doesn't exist
            throw Abort.notFound
        }
        return try JSON(node: course.groups().all().makeNode(context: GroupResponseContext()))
    }

    public func addGroup(request: Request) throws -> ResponseRepresentable {
        guard let courseId = request.parameters["id"]?.int else {
            // Bad course id in request
            throw Abort.badRequest
        }
        guard let course = try Course.find(courseId) else {
            // Course doesn't exist
            return try Response(status: .notFound, headers: ["Content-Type" : "application/json"], body: JSON(node: ["failure": "Course does not exist"]))
        }
        guard let name = request.json?["name"]?.string else {
            return try JSON(node: ["error": "Group name required"])
        }
        var newGroup = Group(name: name, courseid: courseId)
        try newGroup.save()
        return newGroup
    }

}
