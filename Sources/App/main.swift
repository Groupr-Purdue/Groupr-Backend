import Vapor
import VaporSQLite
import Fluent
import Auth
import Foundation
import Cookies
import Library

// Establish AuthMiddleware for Cookies.
let auth = AuthMiddleware(user: Library.User.self) { value in
    return Cookie(
        name: "Groupr-Backend",
        value: value,
        expires: Date().addingTimeInterval(60 * 60 * 5), // 5 hours
        secure: true,
        httpOnly: true
    )
}

// Initialize root Droplet.
let drop = Droplet()
drop.middleware.insert(CORSMiddleware(), at: 0)
//drop.middleware.append(auth)
try drop.addProvider(VaporSQLite.Provider.self)

/*
let error = Abort.custom(status: .forbidden, message: "Invalid credentials.")
let protect = ProtectMiddleware(error: error)
drop.grouped(protect).group("secure") { secure in
    secure.get("about") { req in
        let user = try req.user()
        return user
    }
}
*/

// Prepare the SQLite DB if needed on boot.
// TODO: Move to Model classes.
let preparations = [
    Group.self,
    Library.Event.self,
    Library.User.self,
    Course.self,
    Pivot<Library.User, Course>.self,
    Pivot<Group, Course>.self,
    Pivot<Group, Library.Event>.self
] as [Preparation.Type]
drop.preparations += preparations

// Define the set of all controllers with named endpoints.
// TODO: Dynamically collect controllers.
drop.resource("/users", UsersController(droplet: drop))
drop.resource("/courses", CoursesController(droplet: drop))
drop.resource("/groups", GroupsController(droplet: drop))
drop.resource("/events", EventsController(droplet: drop))
drop.run()
