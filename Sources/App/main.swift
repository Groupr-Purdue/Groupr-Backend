import Vapor
import VaporPostgreSQL
import Fluent
import Auth
import Foundation
import Cookies
import Library


// Initialize root Droplet.
let drop = Droplet()
drop.middleware.insert(CORSMiddleware(), at: 0)
try drop.addProvider(VaporPostgreSQL.Provider.self)

// Prepare the SQLite DB if needed on boot.
// TODO: Move to Model classes.
drop.preparations += [
    Group.self,
    Library.Event.self,
    Library.User.self,
    Course.self,
    Pivot<Library.User, Course>.self,
    Pivot<Group, Course>.self,
    Pivot<Group, Library.Event>.self
] as [Preparation.Type]

// Create all endpoint controllers.
let authenticate = AuthController(droplet: drop)
let users = UsersController(droplet: drop)
let courses = CoursesController(droplet: drop)
let groups = GroupsController(droplet: drop)
let events = EventsController(droplet: drop)

// Define the set of all controllers with named endpoints.
// TODO: Dynamically collect controllers.
drop.post("/login", handler: authenticate.login)
drop.delete("/logout", handler: authenticate.logout)
drop.get("/me", handler: authenticate.me)

users.registerRoutes()
drop.resource("/users", users)
drop.resource("/courses", courses)
drop.resource("/groups", groups)
drop.resource("/events", events)


// Enable WebSocket realtime communication.
drop.socket("/realtime", String.self, handler: RealtimeController.handle)
drop.run()
