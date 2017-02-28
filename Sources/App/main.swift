import Vapor
import VaporSQLite
import Fluent
import Auth
import Foundation
import Cookies
import Library

// Establish AuthMiddleware for Cookies and ProtectMiddleware.
let auth = AuthMiddleware(user: Library.User.self) { value in
    return Cookie(
        name: "Groupr-Backend",
        value: value,
        expires: Date().addingTimeInterval(60 * 60 * 5), // 5 hours
        secure: true,
        httpOnly: true
    )
}
let protect = ProtectMiddleware(error:
    Abort.custom(status: .forbidden, message: "Invalid credentials.")
)

// Initialize root Droplet.
let drop = Droplet()
drop.middleware.insert(CORSMiddleware(), at: 0)
drop.middleware.append(auth)
try drop.addProvider(VaporSQLite.Provider.self)

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

// Create all endpoint controllers.
let authenticate = AuthController(droplet: drop)
let users = UsersController(droplet: drop)
let courses = CoursesController(droplet: drop)
let groups = GroupsController(droplet: drop)
let events = EventsController(droplet: drop)

// Define the set of all controllers with named endpoints.
// TODO: Dynamically collect controllers.
drop.post("/authenticate") { request in
    let user = try users.store(request: request)
    return user//try JSON(node: ["auth": "success", "user": user])
}
drop.get("/authenticate", handler: authenticate.login)
drop.delete("/authenticate", handler: authenticate.logout)
drop.get("/me", handler: authenticate.me)
drop.group(protect) { route in
    route.resource("/users", users)
    route.resource("/courses", courses)
    route.resource("/groups", groups)
    route.resource("/events", events)
}
drop.run()
