//
//  Enrollment.swift
//  backend
//
//  Created by William Huang on 3/17/17.
//
//

import Vapor

public final class Enrollment: Model {
    
    public static var entity = "course_user"
    
    var courseId: Node
    var userId: Node
    var isStaff: Bool
    
    // MARK: Model
    
    public var id: Node?
    public var exists: Bool = false
    
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "course_id": courseId,
            "user_id": userId,
            "is_staff": isStaff,
            ])
    }
    
    public init(node: Node, in context: Context) throws {
        self.id = try node.extract("id")
        self.courseId = try node.extract("course_id")
        self.userId = try node.extract("user_id")
        self.isStaff = try node.extract("is_staff")
    }
    
    public static func prepare(_ database: Database) throws {
        try database.create("course_user") { course_user in
            course_user.id()
            course_user.int("course_id")
            course_user.int("user_id")
            course_user.bool("is_staff")
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete("course_user")
    }
    
}
