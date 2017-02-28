import Vapor
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

    /// GET /: Show all course entries.
    public func index(request: Request) throws -> ResponseRepresentable {
        let json = try JSON(node: Course.all().makeNode())
        return json
    }

    /// POST: Add a new course entry.
    public func store(request: Request) throws -> ResponseRepresentable {
        var course = try request.course()
        try course.save()
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
        return course
    }

    /// DELETE: Delete the course entry and return the course that was deleted.
    public func destroy(request: Request, course: Course) throws -> ResponseRepresentable {
        let ret_course = course
        try course.delete()
        return ret_course
    }
}
