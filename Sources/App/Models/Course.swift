import Vapor
import Fluent

final class Course: Model {
    var id: Node?
    var exists: Bool = false
    
    var name: String
    var enrollment: Int
    
    init(name: String, enrollment: Int) {
        self.id = nil
        self.name = name
        self.enrollment = enrollment
    }
    
    init(node: Node, in context: Context) throws {
        self.id = try node.extract("id")
        self.name = try node.extract("name")
        self.enrollment = try node.extract("enrollment")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "enrollment": enrollment
        ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("courses", closure: { (courses) in
            courses.id()
            courses.string("name", length: nil, optional: false, unique: true, default: nil)
            courses.int("enrollment", optional: true)
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("courses")
    }
}
