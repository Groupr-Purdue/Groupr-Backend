import Vapor
import HTTP

final class CoursesController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable{
        let json = try JSON(node: Course.all().makeNode())
        return json
    }
    
    func store(request: Request) throws -> ResponseRepresentable{
        var course = try request.course()
        try course.save()
        return course
    }
    
    func show(request: Request, course: Course) throws -> ResponseRepresentable{
        return course
    }
    
    func destroy(request: Request, course: Course) throws -> ResponseRepresentable{
        try course.delete()
        return JSON([:])
    }
    
    func update(request: Request, course: Course) throws -> ResponseRepresentable{
        let newCourse = try request.course()
        var course = course
        course.title = newCourse.title
        course.name = newCourse.name
        course.enrollment = newCourse.enrollment
        try course.save()
        return course
    }
    
    public func makeResource() -> Resource<Course> {
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
    func course() throws -> Course {
        guard let json = self.json else {
            throw Abort.badRequest
        }
        return try Course(node: json)
    }
}
